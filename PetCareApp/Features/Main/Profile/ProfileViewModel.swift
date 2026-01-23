//
//  ProfileViewModel.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 05.01.26.
//

import Combine
import Foundation

@MainActor
final class ProfileViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var user: UserProfile?
    @Published var household: Household?
    @Published var newHouseholdName: String = ""
    @Published var joinCodeInput: String = ""
    @Published var alert: AppAlert?
    @Published private(set) var state: ScreenState = .loading
    
    @Published var selectedTheme: AppTheme = .system {
        didSet { themeManager.setTheme(selectedTheme) }
    }
    
    // MARK: - Editing UI State
    
    @Published var isEditingProfile: Bool = false
    @Published var draftFullName: String = ""
    @Published var draftImageData: Data? = nil
    
    var canSaveProfile: Bool {
        guard let user else { return false }
        let nameChanged = draftFullName.trimmed != (user.fullName ?? "").trimmed && !draftFullName.isEmptyOrWhitespace
        let photoChanged = draftImageData != nil
        return nameChanged || photoChanged
    }
    
    // MARK: - Private Properties
    
    private let authService: AuthServiceProtocol
    private let userService: UserServiceProtocol
    private let imageStorageService: ImageStorageServiceProtocol
    private let householdService: HouseholdServiceProtocol
    private let themeManager: ThemeManaging
    
    // MARK: - Computed Properties
    
    var isUserInHousehold: Bool {
        household != nil
    }
    
    var userFullName: String {
        user?.fullName ?? "User"
    }
    
    var userEmail: String {
        user?.email ?? "No Email"
    }
    
    var householdName: String {
        household?.name ?? "No Household"
    }
    
    var householdMemberCount: Int {
        household?.memberIds.count ?? 0
    }
    
    var householdJoinCode: String {
        household?.joinCode ?? "N/A"
    }
    
    // MARK: - Initializer
    
    init(
        authService: AuthServiceProtocol,
        userService: UserServiceProtocol,
        imageStorageService: ImageStorageServiceProtocol,
        householdService: HouseholdServiceProtocol,
        themeManager: ThemeManaging
    ) {
        self.authService = authService
        self.userService = userService
        self.imageStorageService = imageStorageService
        self.householdService = householdService
        self.themeManager = themeManager
        
        self.selectedTheme = themeManager.theme
    }
    
    // MARK: - Methods
    
    func loadProfile() async {
        state = .loading
        
        do {
            guard let userId = authService.currentUserId else { return }
            
            let userProfile = try await userService.getUser(userId: userId)
            self.user = userProfile
            
            if let householdId = userProfile.householdId {
                household = try await householdService.getHousehold(id: householdId)
            } else {
                household = nil
            }
            
            if isEditingProfile == false {
                draftFullName = userProfile.fullName ?? ""
                draftImageData = nil
            }
            
            state = .loaded
        } catch {
            state = .error(error.localizedDescription)
        }
    }
    
    func startEditingProfile() {
        guard let user else { return }
        draftFullName = user.fullName ?? ""
        draftImageData = nil
        isEditingProfile = true
    }
    
    func cancelEditingProfile() {
        if let user {
            draftFullName = user.fullName ?? ""
        }
        draftImageData = nil
        isEditingProfile = false
    }
    
    func saveProfileChanges() async {
        guard let userId = authService.currentUserId else { return }
        
        state = .loading
        
        do {
            var newPhotoURL: String? = user?.photoUrl
            
            if let data = draftImageData {
                newPhotoURL =
                try await imageStorageService.uploadUserProfileImage(
                    userId: userId,
                    data: data
                )
            }
            
            let nameToSave: String? =
            draftFullName.isEmptyOrWhitespace ? nil : draftFullName.trimmed
            
            try await userService.updateUserProfile(
                userId: userId,
                fullName: nameToSave,
                photoUrl: newPhotoURL
            )
            
            isEditingProfile = false
            draftImageData = nil
            
            await loadProfile()
            state = .loaded
        } catch {
            alert = .error(error.localizedDescription)
            state = .loaded
        }
    }
    
    func createHousehold() async {
        guard !newHouseholdName.isEmpty, let userId = user?.id else { return }
        
        state = .loading
        
        do {
            let newHouse = try await householdService.createHousehold(
                name: newHouseholdName,
                adminId: userId
            )
            
            if let houseId = newHouse.id {
                try await userService.updateUserHousehold(
                    userId: userId,
                    householdId: houseId
                )
            }
            
            await loadProfile()
            newHouseholdName = ""
            
            alert = .success(
                "Household created! Share code: \(newHouse.joinCode)"
            )
            state = .loaded
            
        } catch {
            alert = .error(error.localizedDescription)
            state = .loaded
        }
    }
    
    func joinHousehold() async {
        guard !joinCodeInput.isEmpty, let userId = user?.id else { return }
        
        state = .loading
        
        do {
            let house = try await householdService.joinHousehold(
                code: joinCodeInput.uppercased(),
                userId: userId
            )
            
            if let houseId = house.id {
                try await userService.updateUserHousehold(
                    userId: userId,
                    householdId: houseId
                )
            }
            
            await loadProfile()
            joinCodeInput = ""
            
            alert = .success("Joined \(house.name) successfully!")
            state = .loaded
            
        } catch {
            alert = .error("Could not join: \(error.localizedDescription)")
            joinCodeInput = ""
            await loadProfile()
        }
    }
    
    func leaveHousehold() async {
        guard let householdId = household?.id,
              let userId = user?.id else { return }
        
        state = .loading
        
        do {
            try await householdService.leaveHousehold(
                id: householdId,
                userId: userId
            )
            
            try await userService.updateUserHousehold(
                userId: userId,
                householdId: nil
            )
            
            await loadProfile()
            
            alert = .success("You have left the household.")
            state = .loaded
            
        } catch {
            alert = .error(error.localizedDescription)
            state = .loaded
        }
    }
    
    func signOut() async {
        state = .loading
        
        do {
            try authService.signOut()
        } catch {
            state = .error("Sign out failed: \(error.localizedDescription)")
        }
    }
}

//
//  ProfileViewModel.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 05.01.26.
//


import Foundation
import Combine

@MainActor
final class ProfileViewModel: ObservableObject {
    
    // MARK: - Properties
    
    @Published var user: UserProfile?
    @Published var household: Household?
    
    @Published var newHouseholdName: String = ""
    @Published var joinCodeInput: String = ""
    
    @Published private(set) var state: ScreenState = .loading
    @Published var activeAlert: ActiveAlert?
    
    enum ActiveAlert: Identifiable {
        case error(String)
        case success(String)
        var id: String {
            switch self {
            case .error(let message): return message
            case .success(let message): return message
            }
        }
    }
    
    private let authService: AuthServiceProtocol
    private let userService: UserServiceProtocol
    private let householdService: HouseholdServiceProtocol
    
    
    // MARK: - Initializer
    
    init(
        authService: AuthServiceProtocol,
        userService: UserServiceProtocol,
        householdService: HouseholdServiceProtocol
    ) {
        self.authService = authService
        self.userService = userService
        self.householdService = householdService
    }
    
    // MARK: - Methods
    
    func loadProfile() async {
        state = .loading
        
        do {
            guard let userId = authService.currentUserId else { return }
            
            let userProfile = try await userService.getUser(userId: userId)
            self.user = userProfile
            
            if let householdId = userProfile.householdId {
                let household = try await householdService.getHousehold(id: householdId)
                self.household = household
            } else {
                self.household = nil
            }
            
            state = .loaded
        } catch {
            state = .error(error.localizedDescription)
        }
    }
    
    func createHousehold() async {
        guard !newHouseholdName.isEmpty else { return }
        guard let userId = user?.id else { return }
        
        state = .loading
        
        do {
            let newHouse = try await householdService.createHousehold(name: newHouseholdName, adminId: userId)
            
            if let houseId = newHouse.id {
                try await userService.updateUserHousehold(userId: userId, householdId: houseId)
            }
            
            await loadProfile()
            newHouseholdName = ""
            activeAlert = .success("Household created! Share code: \(newHouse.joinCode)")
            state = .loaded
            
        } catch {
            activeAlert = .error(error.localizedDescription)
        }
    }
    
    func joinHousehold() async {
        guard !joinCodeInput.isEmpty else { return }
        guard let userId = user?.id else { return }
        
        state = .loading
        
        do {
            let house = try await householdService.joinHousehold(code: joinCodeInput.uppercased(), userId: userId)
            
            if let houseId = house.id {
                try await userService.updateUserHousehold(userId: userId, householdId: houseId)
            }
            
            await loadProfile()
            joinCodeInput = ""
            activeAlert = .success("Joined \(house.name) successfully!")
            
            state = .loaded
        } catch {
            activeAlert = .error("Could not join: \(error.localizedDescription)")
            joinCodeInput = ""
            await loadProfile()
        }
    }
    
    func leaveHousehold() async {
        guard let householdId = household?.id else { return }
        guard let userId = user?.id else { return }
        
        state = .loading
        
        do {
            try await householdService.leaveHousehold(id: householdId, userId: userId)
            
            try await userService.updateUserHousehold(userId: userId, householdId: nil)
            
            self.household = nil
            if var updatedUser = self.user {
                updatedUser.householdId = nil
                self.user = updatedUser
            }
            
            await loadProfile()
            
            activeAlert = .success("You have left the household.")
            state = .loaded
            
        } catch {
            state = .error(error.localizedDescription)
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

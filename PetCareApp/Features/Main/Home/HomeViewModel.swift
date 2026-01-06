//
//  HomeViewModel.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 03.01.26.
//


import Foundation
import Combine

@MainActor
final class HomeViewModel: ObservableObject {
    
    // MARK: - Properties
    
    @Published var user: UserProfile?
    @Published var household: Household?
    @Published var pets: [Pet] = []
    
    @Published private(set) var state: ScreenState = .loading
    
    private let authService: AuthServiceProtocol
    private let userService: UserServiceProtocol
    private let householdService: HouseholdServiceProtocol
    private let petService: PetServiceProtocol
    
    // MARK: - Initializer
    
    init(
        authService: AuthServiceProtocol,
        userService: UserServiceProtocol,
        householdService: HouseholdServiceProtocol,
        petService: PetServiceProtocol
    ) {
        self.authService = authService
        self.userService = userService
        self.householdService = householdService
        self.petService = petService
    }
    
    // MARK: - Methods
    
    func loadData() async {
        state = .loading
        
        do {
            guard let userId = authService.currentUserId else {
                state = .error("User not authenticated.");
                return
            }
            
            let userProfile = try await userService.getUser(userId: userId)
            self.user = userProfile
            
            if let householdId = userProfile.householdId {
                async let houseTask = householdService.getHousehold(id: householdId)
                async let petsTask = petService.getPets(forHousehold: householdId)
                
                let (fetchedHouse, fetchedPets) = try await (houseTask, petsTask)
                self.household = fetchedHouse
                self.pets = fetchedPets
            } else {
                self.household = nil
                self.pets = []
            }
            
            state = .loaded
            
        } catch {
            state = .error(error.localizedDescription)
        }
    }
}

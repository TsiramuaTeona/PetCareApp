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
    
    // MARK: - State Properties
    
    @Published var user: UserProfile?
    @Published var household: Household?
    @Published var pets: [Pet] = []
    @Published var upcomingReminders: [ReminderItem] = []
    @Published var dailyFact: String = ""
    
    @Published private(set) var state: ScreenState = .loading
    
    // MARK: - Services Properties
    
    private let authService: AuthServiceProtocol
    private let userService: UserServiceProtocol
    private let householdService: HouseholdServiceProtocol
    private let petService: PetServiceProtocol
    private let healthService: HealthServiceProtocol
    private let reminderSyncService: ReminderSyncServiceProtocol
    
    // MARK: - Initializer
    
    init(
        authService: AuthServiceProtocol,
        userService: UserServiceProtocol,
        householdService: HouseholdServiceProtocol,
        petService: PetServiceProtocol,
        healthService: HealthServiceProtocol,
        reminderSyncService: ReminderSyncServiceProtocol
    ) {
        self.authService = authService
        self.userService = userService
        self.householdService = householdService
        self.petService = petService
        self.healthService = healthService
        self.reminderSyncService = reminderSyncService
    }
    
    // MARK: - Methods
    
    func loadData() async {
        state = .loading
        dailyFact = FunFactService.getRandomFact()
        
        do {
            guard let userId = authService.currentUserId else {
                state = .error("User not authenticated")
                return
            }
            
            let userProfile = try await userService.getUser(userId: userId)
            self.user = userProfile
            
            guard let householdId = userProfile.householdId else {
                self.household = nil
                self.pets = []
                self.upcomingReminders = []
                state = .loaded
                return
            }
            
            async let householdTask = householdService.getHousehold(id: householdId)
            async let petsTask = petService.getPets(forHousehold: householdId)
            
            let (household, pets) = try await (householdTask, petsTask)
            
            self.household = household
            self.pets = pets
            
            await loadReminders(for: pets)
            
            Task {
                await reminderSyncService.syncAllReminders(forHousehold: householdId)
            }
            
            state = .loaded
            
        } catch {
            state = .error(error.localizedDescription)
        }
    }
    
    func refreshFact() {
        dailyFact = FunFactService.getRandomFact()
    }
    
    private func loadReminders(for pets: [Pet]) async {
        var allItems: [ReminderItem] = []
        
        await withTaskGroup(of: [ReminderItem].self) { group in
            for pet in pets {
                group.addTask {
                    guard let petId = await pet.id else { return [] }
                    guard let logs = try? await self.healthService.fetchLogs(petId: petId) else { return [] }
                    
                    return logs.filter { !$0.isResolved && $0.nextDueDate != nil }
                        .map { ReminderItem(petId: petId, petName: pet.name, petPhoto: pet.photoUrl, log: $0) }
                }
            }
            
            for await items in group {
                allItems.append(contentsOf: items)
            }
        }
        
        self.upcomingReminders = Array(allItems
            .sorted { ($0.log.nextDueDate ?? .distantFuture) < ($1.log.nextDueDate ?? .distantFuture) }
        )
    }
}

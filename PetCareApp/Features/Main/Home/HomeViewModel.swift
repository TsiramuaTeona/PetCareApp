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
    
    // MARK: - Task Management
    
    private var loadTask: Task<Void, Never>?
    
    // MARK: - Listening State
    
    private var listeningHouseholdId: String?
    
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
    
    // MARK: - Deinitializer
    
    deinit {
        loadTask?.cancel()
    }
    
    // MARK: - Methods
    
    func loadData() async {
        loadTask?.cancel()
        
        let task = Task { [weak self] in
            guard let self else { return }
            await self.performLoad()
        }
        
        loadTask = task
        await task.value
    }
    
    func refreshFact() {
        dailyFact = FunFactService.getRandomFact()
    }
    
    // MARK: - Private Methods
    
    private func performLoad() async {
        state = .loading
        dailyFact = FunFactService.getRandomFact()
        
        do {
            guard let userId = authService.currentUserId else {
                clearHomeDataForLogout()
                state = .error("User not authenticated")
                return
            }
            
            let userProfile = try await userService.getUser(userId: userId)
            user = userProfile
            
            guard let householdId = userProfile.householdId, !householdId.isEmpty else {
                stopHouseholdListeningIfNeeded()
                household = nil
                pets = []
                upcomingReminders = []
                state = .loaded
                return
            }
            
            async let householdTask = householdService.getHousehold(id: householdId)
            async let petsTask = petService.getPets(forHousehold: householdId)
            
            let (household, pets) = try await (householdTask, petsTask)
            
            self.household = household
            self.pets = pets
            
            let reminders = try await fetchUpcomingReminders(for: pets)
            self.upcomingReminders = reminders
            
            if listeningHouseholdId != householdId {
                await reminderSyncService.syncAllReminders(forHousehold: householdId)
                await reminderSyncService.startListeningForHousehold(householdId)
                listeningHouseholdId = householdId
            }
            
            state = .loaded
        } catch is CancellationError {
            
        } catch {
            state = .error(error.localizedDescription)
        }
    }
    
    private func clearHomeDataForLogout() {
        stopHouseholdListeningIfNeeded()
        
        user = nil
        household = nil
        pets = []
        upcomingReminders = []
    }
    
    private func stopHouseholdListeningIfNeeded() {
        reminderSyncService.stopListening()
        listeningHouseholdId = nil
    }
    
    private func fetchUpcomingReminders(for pets: [Pet]) async throws -> [ReminderItem] {
        let healthService = self.healthService
        
        let petSnapshots: [(id: String, name: String, photoUrl: String?)] = pets.compactMap { pet in
            guard let id = pet.id, !id.isEmpty else { return nil }
            return (id: id, name: pet.name, photoUrl: pet.photoUrl)
        }
        
        var allItems: [ReminderItem] = []
        allItems.reserveCapacity(32)
        
        try await withThrowingTaskGroup(of: [ReminderItem].self) { group in
            for pet in petSnapshots {
                group.addTask(priority: .utility) {
                    let logs = try await healthService.fetchLogs(petId: pet.id)
                    
                    return logs
                        .filter { !$0.isResolved && $0.nextDueDate != nil }
                        .map {
                            ReminderItem(
                                petId: pet.id,
                                petName: pet.name,
                                petPhoto: pet.photoUrl,
                                log: $0
                            )
                        }
                }
            }
            
            for try await items in group {
                allItems.append(contentsOf: items)
            }
        }
        
        return allItems.sorted {
            ($0.log.nextDueDate ?? .distantFuture) < ($1.log.nextDueDate ?? .distantFuture)
        }
    }
}

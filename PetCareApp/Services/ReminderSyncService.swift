//
//  ReminderSyncService.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 10.01.26.
//


import Foundation

// MARK: - ReminderSyncServiceProtocol

protocol ReminderSyncServiceProtocol {
    func syncAllReminders(forHousehold householdId: String) async
    func scheduleReminder(for log: HealthLog) async
}

// MARK: - ReminderSyncService

final class ReminderSyncService: ReminderSyncServiceProtocol {
    // MARK: - Properties
    
    private let petService: PetServiceProtocol
    private let healthService: HealthServiceProtocol
    private let notificationManager = NotificationManager.shared
    
    // MARK: - Initializer
    
    init(petService: PetServiceProtocol, healthService: HealthServiceProtocol) {
        self.petService = petService
        self.healthService = healthService
    }
    
    // MARK: - Methods
    
    func syncAllReminders(forHousehold householdId: String) async {
        do {
            let pets = try await petService.getPets(forHousehold: householdId)
            
            notificationManager.cancelAllPendingReminders()
            
            for pet in pets {
                guard let petId = pet.id else { continue }
                
                let logs = try await healthService.fetchLogs(petId: petId)
                
                let activeLogs = logs.filter { log in
                    guard !log.isResolved else { return false }
                    if let nextDue = log.nextDueDate, nextDue > Date() { return true }
                    if let reminders = log.reminderTimes, !reminders.isEmpty { return true }
                    return false
                }
                
                for log in activeLogs {
                    notificationManager.scheduleNotification(for: log, petName: pet.name)
                }
            }
        } catch {
            print("Sync failed: \(error.localizedDescription)")
        }
    }
    
    func scheduleReminder(for log: HealthLog) async {
        guard let pet = try? await petService.getPet(petId: log.petId) else { return }
        
        await MainActor.run {
            notificationManager.scheduleNotification(for: log, petName: pet.name)
        }
    }
}

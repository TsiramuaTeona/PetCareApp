//
//  ReminderSyncService.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 10.01.26.
//

import FirebaseFirestore
import Foundation
import os

// MARK: - ReminderSyncServiceProtocol

protocol ReminderSyncServiceProtocol {
    func syncAllReminders(forHousehold householdId: String) async
    func scheduleReminder(for log: HealthLog) async
    
    func startListeningForHousehold(_ householdId: String) async
    func stopListening()
}

// MARK: - ReminderSyncService

final class ReminderSyncService: ReminderSyncServiceProtocol {
    
    // MARK: - Properties
    
    private let petService: PetServiceProtocol
    private let healthService: HealthServiceProtocol
    private let notificationService: NotificationServiceProtocol
    
    private let db = Firestore.firestore()
    private var listeners: [ListenerRegistration] = []
    
    // MARK: - Initializer
    
    init(
        petService: PetServiceProtocol,
        healthService: HealthServiceProtocol,
        notificationService: NotificationServiceProtocol
    ) {
        self.petService = petService
        self.healthService = healthService
        self.notificationService = notificationService
    }
    
    // MARK: - Deinitializer
    
    deinit {
        stopListening()
    }
    
    // MARK: - Methods
    
    func syncAllReminders(forHousehold householdId: String) async {
        do {
            let pets = try await petService.getPets(forHousehold: householdId)
            
            notificationService.cancelAllPendingReminders()
            
            try await withThrowingTaskGroup(of: Void.self) { [healthService] group in
                for pet in pets {
                    guard let petId = pet.id, !petId.isEmpty else { continue }
                    let petName = pet.name
                    
                    group.addTask(priority: .utility) {
                        let logs = try await healthService.fetchLogs(
                            petId: petId
                        )
                        
                        for log in logs {
                            if await ReminderSyncService.shouldSchedule(
                                log: log
                            ) {
                                await self.notificationService.scheduleNotification(
                                        for: log,
                                        petName: petName
                                    )
                            } else {
                                await self.notificationService.cancelNotification(for: log)
                            }
                        }
                    }
                }
                
                try await group.waitForAll()
            }
        } catch is CancellationError {
            
        } catch {
            AppLogger.services.error("Reminder sync failed: \(error.localizedDescription)")
        }
    }
    
    func scheduleReminder(for log: HealthLog) async {
        do {
            if ReminderSyncService.shouldSchedule(log: log) {
                let pet = try await petService.getPet(petId: log.petId)
                notificationService.scheduleNotification(
                    for: log,
                    petName: pet.name
                )
            } else {
                notificationService.cancelNotification(for: log)
            }
        } catch {
            AppLogger.services.error("Failed to schedule reminder: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Live Sync
    
    func startListeningForHousehold(_ householdId: String) async {
        stopListening()
        
        do {
            let pets = try await petService.getPets(forHousehold: householdId)
            
            for pet in pets {
                guard let petId = pet.id, !petId.isEmpty else { continue }
                let petName = pet.name
                
                let reg = db
                    .collection("pets")
                    .document(petId)
                    .collection("healthLogs")
                    .addSnapshotListener { [weak self] snapshot, error in
                        guard let self = self else { return }
                        
                        if let error = error {
                            AppLogger.services.error("Listener error: \(error.localizedDescription)")
                            return
                        }
                        
                        guard let snapshot = snapshot else { return }
                        
                        for change in snapshot.documentChanges {
                            guard
                                let log = try? change.document.data(
                                    as: HealthLog.self
                                )
                            else { continue }
                            
                            switch change.type {
                            case .added, .modified:
                                if ReminderSyncService.shouldSchedule(log: log) {
                                    self.notificationService.scheduleNotification(
                                            for: log,
                                            petName: petName
                                        )
                                } else {
                                    self.notificationService.cancelNotification(
                                        for: log
                                    )
                                }
                                
                            case .removed:
                                self.notificationService.cancelNotification(
                                    for: log
                                )
                            }
                        }
                    }
                
                listeners.append(reg)
            }
        } catch {
            AppLogger.services.error("Failed to start listening: \(error.localizedDescription)" )
        }
    }
    
    func stopListening() {
        listeners.forEach { $0.remove() }
        listeners.removeAll()
    }
    
    // MARK: - Rules
    
    private static func shouldSchedule(log: HealthLog) -> Bool {
        guard !log.isResolved else { return false }
        
        let now = Date()
        
        if log.isMedication, let times = log.reminderTimes, !times.isEmpty {
            guard let next = MedicationScheduler.findNextDose(from: times, now: now) else {
                return false
            }
            
            if let duration = log.durationDays {
                let start = (log.medicationCourseStart ?? log.date).startOfDay
                let lastDay = start.adding(days: max(0, duration - 1))
                let end = lastDay.endOfDay
                return next <= end
            }
            
            return next > now
        }
        
        if let due = log.nextDueDate {
            return due > now
        }
        
        return false
    }
}

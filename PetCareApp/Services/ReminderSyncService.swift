//
//  ReminderSyncService.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 10.01.26.
//

import FirebaseFirestore
import Foundation

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
    private let notificationManager = NotificationManager.shared
    
    private let db = Firestore.firestore()
    private var listeners: [ListenerRegistration] = []
    
    // MARK: - Initializer
    
    init(petService: PetServiceProtocol, healthService: HealthServiceProtocol) {
        self.petService = petService
        self.healthService = healthService
    }
    
    // MARK: - Deinitializer
    
    deinit {
        stopListening()
    }
    
    // MARK: - Methods
    
    func syncAllReminders(forHousehold householdId: String) async {
        do {
            let pets = try await petService.getPets(forHousehold: householdId)
            
            notificationManager.cancelAllPendingReminders()
            
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
                                await NotificationManager.shared
                                    .scheduleNotification(
                                        for: log,
                                        petName: petName
                                    )
                            } else {
                                await NotificationManager.shared
                                    .cancelNotification(for: log)
                            }
                        }
                    }
                }
                
                try await group.waitForAll()
            }
        } catch is CancellationError {
            
        } catch {
            print("Sync failed: \(error.localizedDescription)")
        }
    }
    
    func scheduleReminder(for log: HealthLog) async {
        do {
            if ReminderSyncService.shouldSchedule(log: log) {
                let pet = try await petService.getPet(petId: log.petId)
                notificationManager.scheduleNotification(
                    for: log,
                    petName: pet.name
                )
            } else {
                notificationManager.cancelNotification(for: log)
            }
        } catch {
            print("Failed to schedule reminder: \(error.localizedDescription)")
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
                            print("Listener error: \(error.localizedDescription)")
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
                                if ReminderSyncService.shouldSchedule(log: log)
                                {
                                    self.notificationManager
                                        .scheduleNotification(
                                            for: log,
                                            petName: petName
                                        )
                                } else {
                                    self.notificationManager.cancelNotification(
                                        for: log
                                    )
                                }
                                
                            case .removed:
                                self.notificationManager.cancelNotification(
                                    for: log
                                )
                            }
                        }
                    }
                
                listeners.append(reg)
            }
        } catch {
            print("Failed to start listening: \(error.localizedDescription)")
        }
    }
    
    func stopListening() {
        listeners.forEach { $0.remove() }
        listeners.removeAll()
    }
    
    // MARK: - Rules
    
    private static func shouldSchedule(log: HealthLog) -> Bool {
        guard !log.isResolved else { return false }
        
        if let times = log.reminderTimes, !times.isEmpty {
            return true
        }
        
        if let due = log.nextDueDate, due > Date() {
            return true
        }
        
        return false
    }
}

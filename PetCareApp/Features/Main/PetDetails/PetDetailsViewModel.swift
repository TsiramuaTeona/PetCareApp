//
//  PetDetailsViewModel.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 03.01.26.
//


import Foundation
import Combine

@MainActor
final class PetDetailsViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published private(set) var pet: Pet
    @Published var upcomingAlerts: [HealthLog] = []
    @Published var historyLogs: [HealthLog] = []
    @Published private(set) var state: ScreenState = .loading
    @Published var alert: AppAlert?
    
    // MARK: - Private Properties
    
    private let petService: PetServiceProtocol
    private let healthService: HealthServiceProtocol
    private let notificationManager = NotificationManager.shared
    
    // MARK: - Computed Properties
    
    var petId: String {
        pet.id ?? ""
    }
    
    var weightText: String {
        "\(historyLogs.filter { $0.category == .weight }.first?.value, default: "-") kg"
    }
    
    var weightLogs: [HealthLog] {
        historyLogs.filter { $0.category == .weight }
    }
    
    var medicationLogs: [HealthLog] {
        upcomingAlerts.filter { $0.category == .medication }
    }
    
    // MARK: - Initializer
    
    init(
        pet: Pet,
        petService: PetServiceProtocol,
        healthService: HealthServiceProtocol
    ) {
        self.pet = pet
        self.petService = petService
        self.healthService = healthService
    }
    
    // MARK: - Public Methods
    
    func refresh() async {
        guard let petId = pet.id else { return }
        
        do {
            async let petTask = petService.getPet(petId: petId)
            async let logsTask = healthService.fetchLogs(petId: petId)
            let (fetchedPet, allLogs) = try await (petTask, logsTask)
            
            self.pet = fetchedPet
            processLogs(allLogs)
            state = .loaded
        } catch {
            state = .error(error.localizedDescription)
        }
    }
    
    func resolveLog(_ log: HealthLog) async {
        guard let _ = log.id else { return }
        
        let now = Date()
        
        var historyLog = log
        historyLog.isResolved = true
        historyLog.completedDate = now
    
        historyLog.date = now
        
        historyLog.nextDueDate = nil
        
        if let nextLog = LogScheduler.generateNextLog(currentLog: log, completionDate: now) {
            await createAndSchedule(nextLog, petName: pet.name)
        }
        
        do {
            try await healthService.updateLog(historyLog)
            notificationManager.cancelNotification(for: log)
            await refresh()
        } catch {
            alert = .error("Failed to update log status.")
        }
    }
    
    func deleteLog(_ log: HealthLog) async {
        guard let id = log.id, let petId = pet.id else { return }
        do {
            try await healthService.deleteLog(petId: petId, logId: id)
            await refresh()
        } catch {
            alert = .error("Could not delete log.")
        }
    }
    
    func applyUpdatedPet(_ updatedPet: Pet) {
        self.pet = updatedPet
    }
    
    func deleteTapped(onSuccess: @escaping () -> Void) {
        alert = .deleteConfirmation(
            title: "Delete \(pet.name)?",
            message: "This action cannot be undone."
        ) { [weak self] in
            Task {
                await self?.deletePet(onSuccess: onSuccess)
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func deletePet(onSuccess: () -> Void) async {
        guard let petId = pet.id else { return }
        do {
            try await petService.deletePet(petId: petId)
            onSuccess()
        } catch {
            alert = .error(error.localizedDescription)
        }
    }
    
    private func processLogs(_ logs: [HealthLog]) {
        let today = Date()
        
        self.upcomingAlerts = logs
            .filter { !$0.isResolved && $0.nextDueDate != nil }
            .sorted { ($0.nextDueDate ?? today) < ($1.nextDueDate ?? today) }
        
        self.historyLogs = logs
            .filter { $0.isResolved || $0.nextDueDate == nil }
            .sorted { $0.date > $1.date }
    }
    
    private func createAndSchedule(_ log: HealthLog, petName: String) async {
        do {
            let newId = try await healthService.addLog(log)
            var scheduledLog = log
            scheduledLog.id = newId
            notificationManager.scheduleNotification(for: scheduledLog, petName: petName)
        } catch {
            alert = .error("Failed to create next recurrence: \(error.localizedDescription)")
        }
    }
}

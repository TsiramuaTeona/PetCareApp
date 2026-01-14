//
//  LogDetailsViewModel.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 13.01.26.
//


import Foundation
import Combine

@MainActor
final class LogDetailsViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var upcomingLogs: [HealthLog] = []
    @Published var historyLogs: [HealthLog] = []
    @Published var chartData: [HealthLog] = []
    
    @Published var sourceLog: HealthLog
    
    @Published private(set) var state: ScreenState = .loading
    
    // MARK: - Private Properties
    
    private let petId: String
    private let healthService: HealthServiceProtocol
    private let reminderService: ReminderSyncServiceProtocol
    private let notificationManager = NotificationManager.shared
    
    // MARK: - Computed Properties
    
    var isWeightCategory: Bool {
        sourceLog.category == .weight
    }
    
    var categoryText: String {
        sourceLog.category.rawValue
    }
    
    var categoryIcon: String {
        sourceLog.category.icon
    }
    
    var hasScheduleInfo: Bool {
        return sourceLog.durationDays != nil ||
        (sourceLog.reminderTimes != nil && !sourceLog.reminderTimes!.isEmpty)
    }
    
    // MARK: - Initializer
    
    init(
        petId: String,
        sourceLog: HealthLog,
        healthService: HealthServiceProtocol,
        reminderService: ReminderSyncServiceProtocol
    ) {
        self.petId = petId
        self.sourceLog = sourceLog
        self.healthService = healthService
        self.reminderService = reminderService
    }
    
    // MARK: - Methods
    
    func refresh() async {
        do {
            let allLogs = try await healthService.fetchLogs(petId: petId)
            filterAndGroup(allLogs)
            state = .loaded
        } catch {
            state = .error(error.localizedDescription)
        }
    }
    
    private func filterAndGroup(_ logs: [HealthLog]) {
        let relatedLogs = logs.filter { log in
            if sourceLog.category == .weight {
                return log.category == .weight
            } else {
                return log.category == sourceLog.category &&
                log.title.localizedCaseInsensitiveContains(sourceLog.title)
            }
        }
        
        let now = Date()
        
        self.upcomingLogs = relatedLogs
            .filter { !$0.isResolved }
            .sorted { ($0.nextDueDate ?? Date.distantFuture) < ($1.nextDueDate ?? Date.distantFuture) }
        
        self.historyLogs = relatedLogs
            .filter { ( $0.isResolved || ($0.nextDueDate ?? Date.distantFuture) < now ) && !$0.isUrgent }
            .sorted { $0.date > $1.date }
        
        self.chartData = self.historyLogs.sorted { $0.date < $1.date }
    }
    
    func saveLogEdits(
        originalLog: HealthLog,
        newDate: Date,
        newNote: String,
        valueString: String,
        dosage: String
    ) async {
        var logToUpdate = originalLog
        
        logToUpdate.date = newDate
        if !logToUpdate.isResolved {
            logToUpdate.nextDueDate = newDate
            logToUpdate.reminderTimes = nil
        }
        
        logToUpdate.note = newNote.trimmed
        
        if logToUpdate.category == .medication {
            logToUpdate.dosage = dosage.trimmed
        }
        
        if logToUpdate.category == .weight {
            if let value = valueString.doubleValue {
                logToUpdate.value = value
            }
        }
        
        if sourceLog.id == logToUpdate.id {
            self.sourceLog = logToUpdate
        }
        
        if let index = upcomingLogs.firstIndex(where: { $0.id == logToUpdate.id }) {
            upcomingLogs[index] = logToUpdate
        }
        
        if let index = historyLogs.firstIndex(where: { $0.id == logToUpdate.id }) {
            historyLogs[index] = logToUpdate
        }
        
        do {
            try await healthService.updateLog(logToUpdate)
            
            if !logToUpdate.isResolved {
                await reminderService.scheduleReminder(for: logToUpdate)
            }
            
        } catch {
            state = .error(error.localizedDescription)
        }
    }
    
    func deleteLog(_ log: HealthLog) async {
        guard let id = log.id else { return }
        try? await healthService.deleteLog(petId: petId, logId: id)
        await refresh()
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
            do {
                let newId = try await healthService.addLog(nextLog)
                
                var scheduledLog = nextLog
                scheduledLog.id = newId
                
                await reminderService.scheduleReminder(for: log)
            } catch {
                state = .error("Failed to schedule next dose: \(error.localizedDescription)")
            }
        }
        
        do {
            try await healthService.updateLog(historyLog)
            notificationManager.cancelNotification(for: log)
            await refresh()
        } catch {
            state = .error(error.localizedDescription)
        }
    }
}

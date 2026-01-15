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
    
    private var groupingKey: String {
        if sourceLog.category == .weight {
            return "weight"
        }
        return "\(sourceLog.category.rawValue)|\(normalize(sourceLog.title))"
    }
    
    // MARK: - Computed Properties
    
    var isWeightCategory: Bool { sourceLog.category == .weight }
    var categoryText: String { sourceLog.category.rawValue }
    var categoryIcon: String { sourceLog.category.icon }
    
    var hasScheduleInfo: Bool {
        return sourceLog.durationDays != nil ||
        (sourceLog.reminderTimes?.isEmpty == false)
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
        state = .loading
        
        do {
            let allLogs = try await healthService.fetchLogs(petId: petId)
            filterAndGroup(allLogs)
            state = .loaded
        } catch {
            state = .error(error.localizedDescription)
        }
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
        logToUpdate.note = newNote.trimmed
        
        if logToUpdate.category == .medication {
            logToUpdate.dosage = dosage.trimmed
        }
        
        if logToUpdate.category == .weight, let value = valueString.doubleValue {
            logToUpdate.value = value
        }
        
        if !logToUpdate.isResolved {
            
            if logToUpdate.category == .medication {
                let frequency = logToUpdate.timesPerDay ?? 1
                let schedule = MedicationScheduler.generateSchedule(
                    start: newDate,
                    frequency: frequency
                )
                
                logToUpdate.reminderTimes = schedule
                logToUpdate.nextDueDate = schedule.first
                
            } else {
                logToUpdate.nextDueDate = newDate
                logToUpdate.reminderTimes = nil
            }
        }
        
        do {
            try await healthService.updateLog(logToUpdate)
            
            notificationManager.cancelNotification(for: logToUpdate)
            
            if !logToUpdate.isResolved {
                await reminderService.scheduleReminder(for: logToUpdate)
            }
            
            await refresh()
        } catch {
            state = .error(error.localizedDescription)
        }
    }
    
    func deleteLog(_ log: HealthLog) async {
        guard let id = log.id else { return }
        
        notificationManager.cancelNotification(for: log)
        
        do {
            try await healthService.deleteLog(petId: petId, logId: id)
            await refresh()
        } catch {
            state = .error(error.localizedDescription)
        }
    }
    
    func resolveLog(_ log: HealthLog) async {
        guard log.id != nil else { return }
        
        let now = Date()
        
        var historyLog = log
        historyLog.isResolved = true
        historyLog.completedDate = now
        historyLog.date = now
        historyLog.nextDueDate = nil
        
        historyLog.reminderTimes = nil
        
        do {
            try await healthService.updateLog(historyLog)
            
            notificationManager.cancelNotification(for: log)
            
            if let nextLog = LogScheduler.generateNextLog(currentLog: log, completionDate: now) {
                let newId = try await healthService.addLog(nextLog)
                
                var scheduledNextLog = nextLog
                scheduledNextLog.id = newId
                
                await reminderService.scheduleReminder(for: scheduledNextLog)
            }
            
            await refresh()
        } catch {
            state = .error(error.localizedDescription)
        }
    }
    
    // MARK: - Private Methods
    
    private func filterAndGroup(_ logs: [HealthLog]) {
        let relatedLogs = logs.filter { log in
            if sourceLog.category == .weight {
                return log.category == .weight
            } else {
                return "\(log.category.rawValue)|\(normalize(log.title))" == groupingKey
            }
        }
        
        let now = Date()
        
        upcomingLogs = relatedLogs
            .filter { !$0.isResolved }
            .sorted { ($0.nextDueDate ?? Date.distantFuture) < ($1.nextDueDate ?? Date.distantFuture) }
        
        
        historyLogs = relatedLogs
            .filter { ( $0.isResolved || ($0.nextDueDate ?? Date.distantFuture) < now ) && !$0.isUrgent }
            .sorted { $0.date > $1.date }
        
        chartData = historyLogs.sorted { $0.date < $1.date }
        
        if let sourceId = sourceLog.id,
           let updatedSource = relatedLogs.first(where: { $0.id == sourceId }) {
            sourceLog = updatedSource
        }
    }
    
    private func normalize(_ string: String) -> String {
        string
            .trimmed
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            .lowercased()
    }
}

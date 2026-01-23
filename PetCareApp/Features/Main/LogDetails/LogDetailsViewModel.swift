//
//  LogDetailsViewModel.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 13.01.26.
//

import Combine
import Foundation

@MainActor
final class LogDetailsViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var upcomingLogs: [HealthLog] = []
    @Published var historyLogs: [HealthLog] = []
    @Published var chartData: [HealthLog] = []
    @Published var sourceLog: HealthLog
    @Published var alert: AppAlert?
    @Published private(set) var state: ScreenState = .loading
    
    // MARK: - Private Properties
    
    private let petId: String
    private let petName: String
    private let healthService: HealthServiceProtocol
    private let reminderService: ReminderSyncServiceProtocol
    private let calendarService: CalendarServiceProtocol
    private let notificationService: NotificationServiceProtocol
    
    private var groupingKey: String {
        if sourceLog.category == .weight {
            return "weight"
        }
        return "\(sourceLog.category.rawValue)|\(sourceLog.title.normalize)"
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
        petName: String,
        sourceLog: HealthLog,
        healthService: HealthServiceProtocol,
        calendarService: CalendarServiceProtocol,
        reminderService: ReminderSyncServiceProtocol,
        notificationService: NotificationServiceProtocol
    ) {
        self.petId = petId
        self.petName = petName
        self.sourceLog = sourceLog
        self.healthService = healthService
        self.calendarService = calendarService
        self.reminderService = reminderService
        self.notificationService = notificationService
    }
    
    // MARK: - Data Loading Methods
    
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
    
    // MARK: - Log Editing Methods
    
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
                let schedule = MedicationScheduler.generateSchedule(start: newDate, frequency: frequency)
                
                logToUpdate.reminderTimes = schedule
                logToUpdate.nextDueDate = newDate
                
            } else {
                logToUpdate.nextDueDate = newDate
                logToUpdate.reminderTimes = nil
            }
        }
        
        do {
            try await healthService.updateLog(logToUpdate)
            
            notificationService.cancelNotification(for: originalLog)
            
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
        
        notificationService.cancelNotification(for: log)
        
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
            
            notificationService.cancelNotification(for: log)
            
            if let nextLog = LogScheduler.generateNextLog(currentLog: log) {
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
    
    // MARK: - Calendar Methods
    
    func requestAddToCalendar() {
        let newAlert = CalendarAlertBuilder.confirmAddToCalendar(
            petName: petName,
            log: sourceLog,
            onConfirm: { [weak self] in
                guard let self else { return }
                Task { await self.addToCalendarConfirmed() }
            }
        )
        
        DispatchQueue.main.async { [weak self] in
            self?.alert = newAlert
        }
    }
    
    private func addToCalendarConfirmed() async {
        do {
            try await calendarService.addHealthLogEvent(
                log: sourceLog,
                petName: petName
            )
            
            DispatchQueue.main.async { [weak self] in
                self?.alert = .success("Added to Calendar 📅")
            }
            
        } catch let calendarError as CalendarError {
            let alertToShow: AppAlert
            
            switch calendarError {
            case .accessDenied:
                alertToShow = .openSettings(message: calendarError.localizedDescription)
            case .accessRestricted:
                alertToShow = .error(calendarError.localizedDescription)
            case .saveFailed:
                alertToShow = .error(calendarError.localizedDescription)
            }
            
            DispatchQueue.main.async { [weak self] in
                self?.alert = alertToShow
            }
            
        } catch {
            DispatchQueue.main.async { [weak self] in
                self?.alert = .error(error.localizedDescription)
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func filterAndGroup(_ logs: [HealthLog]) {
        let relatedLogs = logs.filter { log in
            if sourceLog.category == .weight {
                return log.category == .weight
            } else {
                return "\(log.category.rawValue)|\(log.title.normalize)" == groupingKey
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
}

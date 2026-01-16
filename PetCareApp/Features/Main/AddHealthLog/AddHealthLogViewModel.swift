//
//  AddHealthLogViewModel.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 10.01.26.
//


import Foundation
import Combine

@MainActor
final class AddHealthLogViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var category: LogCategory = .vaccine
    @Published var title: String = ""
    @Published var note: String = ""
    @Published var actionDate: Date = Date()
    
    @Published var dosage: String = ""
    @Published var timesPerDay: Int = 1
    @Published var isChronic: Bool = false
    @Published var durationDays: Double = 7
    
    @Published var valueString: String = ""
    
    @Published var addReminder: Bool = false
    @Published var nextDueDate: Date = Date().addingTimeInterval(86400 * 30)
    @Published var recurrence: RecurrenceRule = .none
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // MARK: - Private Properties
    
    private let petId: String
    private let healthService: HealthServiceProtocol
    private let reminderService: ReminderSyncServiceProtocol
    
    // MARK: - Computed Properties
    
    var isMedication: Bool { category == .medication }
    var isWeight: Bool { category == .weight }
    
    var isHistoryLog: Bool {
        actionDate.startOfDay <= Date().startOfDay
    }
    
    var titlePlaceholder: String { category.titlePlaceholder }
    var titleSuggestions: [String] { category.titleSuggestions }
    var reminderLabel: String { category.reminderLabel(isHistory: isHistoryLog) }
    var hasValueField: Bool { category.hasValueField }
    
    private var resolvedTitle: String {
        category == .weight ? "\(valueString) kg" : title
    }
    
    private var resolvedNote: String? {
        note.trimmed.isEmpty ? nil : note.trimmed
    }
    
    // MARK: - Callbacks
    
    var onSaveSuccess: (() -> Void)?
    
    // MARK: - Initializer
    
    init(
        petId: String,
        category: LogCategory = .vaccine,
        healthService: HealthServiceProtocol,
        reminderService: ReminderSyncServiceProtocol
    ) {
        self.petId = petId
        self.category = category
        self.healthService = healthService
        self.reminderService = reminderService
    }
    
    // MARK: - Public Method
    
    func save() async {
        guard validate() else { return }
        
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }
        
        do {
            if isHistoryLog {
                if isMedication {
                    try await createAndSaveMedicationHistoryLogs()
                } else {
                    try await saveSingleHistoryLog(date: actionDate)
                }
            }
            
            let shouldCreateFuture: Bool = {
                if isMedication { return shouldCreateFutureMedicationLog(now: Date()) }
                if isWeight { return false }
                return (!isHistoryLog) || (isHistoryLog && addReminder)
            }()
            
            if shouldCreateFuture {
                try await createAndSaveFutureLog()
            }
            
            onSaveSuccess?()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    // MARK: - Private Methods
    
    private func shouldCreateFutureMedicationLog(now: Date) -> Bool {
        if isChronic { return true }
        guard let courseEnd = medicationCourseEndDate() else {
            return true
        }
        
        return now <= courseEnd
    }
    
    private func medicationCourseEndDate() -> Date? {
        let days = Int(durationDays)
        guard days > 0 else { return nil }
        
        let start = actionDate.startOfDay
        let lastDay = start.adding(days: max(0, days - 1))
        return lastDay.endOfDay
    }
    
    private func createAndSaveMedicationHistoryLogs() async throws {
        let now = Date()
        let intervalMinutes = Int((24.0 / Double(max(1, timesPerDay))) * 60)
        
        var simulationDate = actionDate
        
        let courseEnd = medicationCourseEndDate()
        
        while simulationDate < now {
            if !isChronic, let end = courseEnd, simulationDate > end {
                break
            }
            
            try await saveSingleHistoryLog(date: simulationDate)
            simulationDate = simulationDate.adding(minutes: intervalMinutes)
        }
    }
    
    private func saveSingleHistoryLog(date: Date) async throws {
        let log = HealthLog(
            id: nil,
            petId: petId,
            category: category,
            title: resolvedTitle,
            note: resolvedNote,
            date: date,
            isResolved: true,
            completedDate: date,
            nextDueDate: nil,
            recurrence: nil,
            value: valueString.doubleValue,
            dosage: isMedication ? dosage : nil,
            timesPerDay: isMedication ? timesPerDay : nil,
            reminderTimes: nil,
            durationDays: nil
        )
        
        _ = try await healthService.addLog(log)
    }
    
    private func createAndSaveFutureLog() async throws {
        
        let schedule = isMedication
        ? MedicationScheduler.generateSchedule(start: actionDate, frequency: timesPerDay)
        : nil
        
        var startTargetDate = isHistoryLog ? nextDueDate : actionDate
        
        if isMedication && isHistoryLog {
            if let next = MedicationScheduler.findNextDose(from: schedule ?? []) {
                startTargetDate = next
            } else {
                return
            }
        }
        
        let log = HealthLog(
            id: nil,
            petId: petId,
            category: category,
            title: resolvedTitle,
            note: resolvedNote,
            date: startTargetDate,
            isResolved: false,
            completedDate: nil,
            nextDueDate: startTargetDate,
            recurrence: isMedication ? .daily : recurrence,
            value: nil,
            dosage: isMedication ? dosage : nil,
            timesPerDay: isMedication ? timesPerDay : nil,
            reminderTimes: schedule,
            durationDays: (isMedication && !isChronic) ? Int(durationDays) : nil
        )
        
        let id = try await healthService.addLog(log)
        var savedLog = log
        savedLog.id = id
        
        await reminderService.scheduleReminder(for: savedLog)
    }
    
    private func validate() -> Bool {
        if category != .weight && title.trimmed.isEmpty {
            errorMessage = "Please enter a title."
            return false
        }
        
        if isMedication {
            if dosage.trimmed.isEmpty {
                errorMessage = "Please enter dosage."
                return false
            }
            if timesPerDay < 1 || timesPerDay > 4 {
                errorMessage = "Frequency must be between 1 and 4."
                return false
            }
            if !isChronic, Int(durationDays) <= 0 {
                errorMessage = "Please choose duration."
                return false
            }
        }
        
        if isWeight && valueString.trimmed.doubleValue == nil {
            errorMessage = "Please enter a valid weight value."
            return false
        }
        
        return true
    }
}

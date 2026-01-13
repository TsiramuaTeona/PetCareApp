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
    
    var isMedication: Bool {
        category == .medication
    }
    
    var isWeight: Bool {
        category == .weight
    }
    
    var isHistoryLog: Bool {
        Calendar.current.startOfDay(for: actionDate) <= Calendar.current.startOfDay(for: Date())
    }
    
    var titlePlaceholder: String {
        category.titlePlaceholder
    }
    
    var titleSuggestions: [String] {
        category.titleSuggestions
    }
    
    var reminderLabel: String {
        category.reminderLabel(isHistory: isHistoryLog)
    }
    
    var hasValueField: Bool {
        category.hasValueField
    }
    
    private var resolvedTitle: String {
        category == .weight ? "\(valueString) kg" : title
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
        isLoading = true
        
        do {
            if isHistoryLog {
                try await createAndSaveHistoryLog()
            }
            
            let shouldScheduleFuture = isMedication || (!isHistoryLog) || (isHistoryLog && addReminder)
            
            if shouldScheduleFuture {
                try await createAndSaveFutureLog()
            }
            
            onSaveSuccess?()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    // MARK: - Private Methods
    
    private func createAndSaveHistoryLog() async throws {
        guard isMedication else {
            try await saveSingleHistoryLog(date: actionDate)
            return
        }
        
        let calendar = Calendar.current
        let now = Date()
        
        let intervalHours = 24.0 / Double(max(1, timesPerDay))
        
        var simulationDate = actionDate
        
        while simulationDate < now {
            if !isChronic {
                if let endDate = calendar.date(byAdding: .day, value: Int(durationDays), to: actionDate),
                   simulationDate > endDate {
                    break
                }
            }
            
            try await saveSingleHistoryLog(date: simulationDate)
            
            simulationDate = simulationDate.addingTimeInterval(intervalHours * 3600)
        }
    }
    
    private func saveSingleHistoryLog(date: Date) async throws {
        let log = HealthLog(
            id: nil,
            petId: petId,
            category: category,
            title: resolvedTitle,
            note: note.isEmpty ? nil : note,
            date: date,
            isResolved: true,
            completedDate: date,
            nextDueDate: nil,
            recurrence: nil,
            value: valueString.doubleValue,
            dosage: dosage,
            timesPerDay: timesPerDay,
            reminderTimes: nil,
            durationDays: nil
        )
        _ = try await healthService.addLog(log)
    }
    
    private func createAndSaveFutureLog() async throws {
        let schedule = isMedication ? MedicationScheduler.generateSchedule(start: actionDate, frequency: timesPerDay) : nil
        
        var startTargetDate = isHistoryLog ? nextDueDate : actionDate
        
        if isMedication && isHistoryLog {
            let intervalHours = 24.0 / Double(max(1, timesPerDay))
            var simulationDate = actionDate
            let now = Date()
            
            while simulationDate < now {
                simulationDate = simulationDate.addingTimeInterval(intervalHours * 3600)
            }
            startTargetDate = simulationDate
        }
        
        let log = HealthLog(
            id: nil, petId: petId,
            category: category,
            title: resolvedTitle,
            note: isHistoryLog ? category.futureNote : (note.isEmpty ? nil : note),
            date: startTargetDate,
            isResolved: false,
            nextDueDate: startTargetDate,
            recurrence: isMedication ? .daily : recurrence,
            value: nil,
            dosage: isMedication ? dosage : nil,
            timesPerDay: isMedication ? timesPerDay : nil,
            reminderTimes: schedule,
            durationDays: (isMedication && !isChronic) ? Int(durationDays) : nil
        )
        
        let id = try await healthService.addLog(log)
        var savedLog = log; savedLog.id = id
        await reminderService.scheduleReminder(for: savedLog)
    }
    
    private func validate() -> Bool {
        if category != .weight && title.trimmingCharacters(in: .whitespaces).isEmpty {
            errorMessage = "Please enter a title."
            return false
        }
        return true
    }
}

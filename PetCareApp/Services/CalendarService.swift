//
//  CalendarService.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 16.01.26.
//

import EventKit
import Foundation

// MARK: - CalendarError

enum CalendarError: LocalizedError {
    case accessDenied
    case accessRestricted
    case saveFailed
    
    var errorDescription: String? {
        switch self {
        case .accessDenied:
            return "Calendar access denied. You can enable it in Settings → Privacy → Calendars."
        case .accessRestricted:
            return "Calendar access is restricted on this device."
        case .saveFailed:
            return "Couldn’t add this to Apple Calendar. Please try again."
        }
    }
}

// MARK: - CalendarServiceProtocol

protocol CalendarServiceProtocol {
    func addHealthLogEvent(
        log: HealthLog,
        petName: String?
    ) async throws
}

// MARK: - CalendarService

final class CalendarService: CalendarServiceProtocol {
    
    // MARK: - Properties
    
    private let store = EKEventStore()
    
    // MARK: - Public Methods
    
    func addHealthLogEvent(
        log: HealthLog,
        petName: String?
    ) async throws {
        
        try await requestAccessIfNeeded()
        
        let start = log.nextDueDate ?? log.date
        
        let durationMinutes = suggestedDurationMinutes(for: log)
        let end = Calendar.current.date(byAdding: .minute, value: durationMinutes, to: start)
        ?? start.addingTimeInterval(TimeInterval(durationMinutes * 60))
        
        let event = EKEvent(eventStore: store)
        event.calendar = store.defaultCalendarForNewEvents
        
        let prefix = (petName?.isEmpty == false) ? "\(petName!): " : ""
        event.title = "\(prefix)\(log.category.rawValue) - \(log.title)"
        
        event.startDate = start
        event.endDate = end
        
        event.notes = buildNotes(from: log)
        
        event.alarms = [EKAlarm(relativeOffset: -60 * 10)]
        
        if log.category != .medication, let rule = log.recurrence, let ekRule = recurrenceRule(for: rule) {
            event.recurrenceRules = [ekRule]
        }
        
        do {
            try store.save(event, span: .thisEvent, commit: true)
        } catch {
            throw CalendarError.saveFailed
        }
    }
    
    // MARK: - Private Methods
    
    private func requestAccessIfNeeded() async throws {
        let status = EKEventStore.authorizationStatus(for: .event)
        
        switch status {
        case .authorized:
            return
        case .notDetermined:
            let granted = try await store.requestFullAccessToEvents()
            if !granted { throw CalendarError.accessDenied }
        case .denied:
            throw CalendarError.accessDenied
        case .restricted:
            throw CalendarError.accessRestricted
        case .fullAccess:
            break
        case .writeOnly:
            break
        @unknown default:
            throw CalendarError.accessDenied
        }
    }
    
    private func suggestedDurationMinutes(for log: HealthLog) -> Int {
        switch log.category {
        case .medication: return 10
        case .weight: return 10
        default: return 30
        }
    }
    
    private func buildNotes(from log: HealthLog) -> String {
        var lines: [String] = []
        
        lines.append("🐾 Category: \(log.category.rawValue)")
        lines.append("📝 Title: \(log.title)")
        
        if let note = log.note, !note.isEmptyOrWhitespace {
            lines.append("")
            lines.append("📌 Notes:")
            lines.append(note.trimmed)
        }
        
        if log.category == .medication {
            if let dosage = log.dosage, !dosage.isEmptyOrWhitespace {
                lines.append("")
                lines.append("💊 Dosage: \(dosage.trimmed)")
            }
            if let times = log.timesPerDay {
                lines.append("⏱️ Times per day: \(times)")
            }
            if let duration = log.durationDays {
                lines.append("📅 Duration: \(duration) day(s)")
            }
        }
        
        if let due = log.nextDueDate {
            lines.append("")
            lines.append(
                "⏰ Next due: \(due.formatted(.dateTime.year().month().day().hour().minute()))"
            )
        }
        
        return lines.joined(separator: "\n")
    }
    
    private func recurrenceRule(for rule: RecurrenceRule) -> EKRecurrenceRule? {
        switch rule {
        case .none:
            return nil
        case .daily:
            return EKRecurrenceRule(recurrenceWith: .daily, interval: 1, end: nil)
        case .weekly:
            return EKRecurrenceRule(recurrenceWith: .weekly, interval: 1, end: nil)
        case .monthly:
            return EKRecurrenceRule(recurrenceWith: .monthly, interval: 1, end: nil)
        case .everyThreeMonths:
            return EKRecurrenceRule(recurrenceWith: .monthly, interval: 3, end: nil)
        case .everySixMonths:
            return EKRecurrenceRule(recurrenceWith: .monthly, interval: 6, end: nil)
        case .yearly:
            return EKRecurrenceRule(recurrenceWith: .yearly, interval: 1, end: nil)
        }
    }
}

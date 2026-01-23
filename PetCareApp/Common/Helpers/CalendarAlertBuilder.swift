//
//  CalendarAlertBuilder.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 16.01.26.
//

import SwiftUI

struct CalendarAlertBuilder {
    
    // MARK: - Methods
    
    static func confirmAddToCalendar(
        petName: String?,
        log: HealthLog,
        onConfirm: @escaping () -> Void
    ) -> AppAlert {
        
        let title = "Add to Calendar?"
        let message = buildMessage(petName: petName, log: log)
        
        return AppAlert(
            title: title,
            message: message,
            primary: .init(title: "Add", style: .default, handler: onConfirm),
            secondary: .init(title: "Cancel", style: .cancel, handler: nil)
        )
    }
    
    // MARK: - Private Methods
    
    private static func buildMessage(petName: String?, log: HealthLog) -> String {
        var lines: [String] = []
        
        if let petName, !petName.isEmptyOrWhitespace {
            lines.append("🐾 Pet: \(petName.trimmed)")
        }
        
        lines.append("🏷️ Category: \(log.category.rawValue)")
        lines.append("📝 Title: \(log.title)")
        
        let whenDate = (log.nextDueDate ?? log.date)
        lines.append(
            "📅 When: \(whenDate.formatted(.dateTime.year().month().day().hour().minute()))"
        )
        
        if log.category == .medication {
            if let dosage = log.dosage, !dosage.trimmed.isEmpty {
                lines.append("💊 Dosage: \(dosage.trimmed)")
            }
            if let times = log.timesPerDay {
                lines.append("⏱️ Times/day: \(times)")
            }
            if let duration = log.durationDays {
                lines.append("🗓️ Duration: \(duration) day(s)")
            }
        }
        
        if let note = log.note, !note.isEmptyOrWhitespace {
            lines.append("")
            lines.append("📌 Notes:")
            lines.append(note.trimmed)
        }
        
        lines.append("")
        lines.append("This will create a Calendar event for the selected date.")
        
        return lines.joined(separator: "\n")
    }
}

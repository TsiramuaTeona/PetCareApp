//
//  LogScheduler.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 12.01.26.
//


import Foundation

struct LogScheduler {
    static func generateNextLog(currentLog: HealthLog, completionDate: Date = Date()) -> HealthLog? {
        
        guard let nextDate = calculateNextDate(for: currentLog, from: completionDate) else { return nil }
        
        if currentLog.isMedication, let duration = currentLog.durationDays {
            let calendar = Calendar.current
            if let endDate = calendar.date(byAdding: .day, value: duration, to: currentLog.date),
               nextDate > endDate {
                return nil
            }
        }
        
        var newLog = currentLog
        newLog.id = nil
        newLog.nextDueDate = nextDate
        newLog.isResolved = false
        newLog.completedDate = nil
        
        return newLog
    }

    private static func calculateNextDate(for log: HealthLog, from completedDate: Date) -> Date? {
        let calendar = Calendar.current
        
        if log.isMedication {
            let intervalHours = 24.0 / Double(max(1, log.timesPerDay ?? 1))
            return completedDate.addingTimeInterval(intervalHours * 3600)
        }
        
        guard let rule = log.recurrence else { return nil }
        
        switch rule {
        case .daily: return calendar.date(byAdding: .day, value: 1, to: completedDate)
        case .weekly: return calendar.date(byAdding: .day, value: 7, to: completedDate)
        case .monthly: return calendar.date(byAdding: .month, value: 1, to: completedDate)
        case .everyThreeMonths: return calendar.date(byAdding: .month, value: 3, to: completedDate)
        case .everySixMonths: return calendar.date(byAdding: .month, value: 6, to: completedDate)
        case .yearly: return calendar.date(byAdding: .year, value: 1, to: completedDate)
        case .none: return nil
        }
    }
}

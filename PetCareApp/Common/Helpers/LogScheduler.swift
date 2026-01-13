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
            let endDate = currentLog.date.adding(days: duration)
            if nextDate > endDate {
                return nil
            }
        }
        
        var newLog = currentLog
        newLog.id = nil
        newLog.isResolved = false
        newLog.completedDate = nil
        newLog.date = nextDate
        newLog.nextDueDate = nextDate
        
        return newLog
    }
    
    private static func calculateNextDate(for log: HealthLog, from completedDate: Date) -> Date? {
        let originalDueDate = log.nextDueDate ?? log.date
        
        let isOverdue = completedDate.startOfDay > originalDueDate.startOfDay
        
        if log.isMedication {
            let timesPerDay = Double(max(1, log.timesPerDay ?? 1))
            let intervalMinutes = Int((24.0 / timesPerDay) * 60)
            
            if isOverdue {
                return originalDueDate.adding(minutes: intervalMinutes)
            } else {
                return completedDate.adding(minutes: intervalMinutes)
            }
        }
        
        guard let rule = log.recurrence else { return nil }
        
        switch rule {
        case .daily:            return originalDueDate.adding(days: 1)
        case .weekly:           return originalDueDate.adding(days: 7)
        case .monthly:          return originalDueDate.adding(months: 1)
        case .everyThreeMonths: return originalDueDate.adding(months: 3)
        case .everySixMonths:   return originalDueDate.adding(months: 6)
        case .yearly:           return originalDueDate.adding(years: 1)
        case .none:             return nil
        }
    }
}

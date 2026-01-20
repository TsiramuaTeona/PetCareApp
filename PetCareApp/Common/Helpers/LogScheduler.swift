//
//  LogScheduler.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 12.01.26.
//

import Foundation

struct LogScheduler {
    
    // MARK: - Public Methods
    
    static func generateNextLog(currentLog: HealthLog) -> HealthLog? {
        guard
            let nextDate = calculateNextDate(for: currentLog) else { return nil }
        
        if currentLog.isMedication, let duration = currentLog.durationDays {
            let start = currentLog.medicationCourseStart ?? currentLog.date
            let startDay = start.startOfDay
            
            let lastDay = startDay.adding(days: max(0, duration - 1))
            let end = lastDay.endOfDay
            
            if nextDate > end {
                return nil
            }
        }

        
        var newLog = currentLog
        newLog.medicationCourseStart = currentLog.medicationCourseStart
        newLog.id = nil
        newLog.isResolved = false
        newLog.completedDate = nil
        newLog.date = nextDate
        newLog.nextDueDate = nextDate
        
        return newLog
    }
    
    // MARK: - Private Methods
    
    private static func calculateNextDate(for log: HealthLog) -> Date? {
        let originalDueDate = log.nextDueDate ?? log.date
        if log.isMedication {
            let timesPerDay = Double(max(1, log.timesPerDay ?? 1))
            let intervalMinutes = Int((24.0 / timesPerDay) * 60)
            
            return originalDueDate.adding(minutes: intervalMinutes)
        }
        
        guard let rule = log.recurrence else { return nil }
        
        switch rule {
        case .daily: return originalDueDate.adding(days: 1)
        case .weekly: return originalDueDate.adding(days: 7)
        case .monthly: return originalDueDate.adding(months: 1)
        case .everyThreeMonths: return originalDueDate.adding(months: 3)
        case .everySixMonths: return originalDueDate.adding(months: 6)
        case .yearly: return originalDueDate.adding(years: 1)
        case .none: return nil
        }
    }
}

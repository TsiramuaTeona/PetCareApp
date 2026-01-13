//
//  HealthLog.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 05.01.26.
//


import Foundation
import FirebaseFirestore
import SwiftUI

struct HealthLog: Codable, Identifiable, Equatable {
    @DocumentID var id: String?
    var petId: String
    var category: LogCategory
    var title: String
    var note: String?
    
    var date: Date
    
    var isResolved: Bool = false
    var completedDate: Date?
    
    var nextDueDate: Date?
    var recurrence: RecurrenceRule?
    
    var value: Double?
    var dosage: String?
    var timesPerDay: Int?
    var reminderTimes: [Date]?
    var durationDays: Int?
}

extension HealthLog {
    var isMedication: Bool { category == .medication }
    
    var isWeight: Bool { category == .weight }
    
    var statusText: String {
        if isResolved { return "Completed" }
        guard let due = nextDueDate else { return "" }
        
        let now = Date()
        
        if due.isInPast {
            if isMedication {
                return "Missed Dose"
            }
            
            let days = Calendar.current.dateComponents([.day], from: due, to: now).day ?? 0
            return "Overdue by \(days) days"
        }
        
        if due.isToday {
            return isMedication ? "Today at \(due.timeString)" : "Due Today"
        }
        
        if due.isTomorrow {
            return isMedication ? "Tomorrow at \(due.timeString)" : "Due Tomorrow"
        }
        
        let days = Calendar.current.dateComponents([.day], from: now, to: due).day ?? 0
        return "In \(days) days"
    }
    
    var isUrgent: Bool {
        guard let due = nextDueDate, !isResolved else { return false }
        return due.isInPast
    }
    
    func isPastEnd(currentDate: Date) -> Bool {
        guard let _ = durationDays, let _ = timesPerDay else { return false }
        return false
    }
    
    var isActionable: Bool {
        guard let due = nextDueDate else { return false }
        
        if due.isInPast { return true }
        
        if category == .medication {
            let earlyAccessTime = due.adding(minutes: -30)
            return Date() >= earlyAccessTime
        }
        
        let windowInDays: Int = {
            guard let recurrence = recurrence else { return 0 }
            
            switch recurrence {
            case .daily:            return 0
            case .weekly:           return 1
            case .monthly:          return 5
            case .everyThreeMonths: return 7
            case .everySixMonths:   return 14
            case .yearly:           return 30
            case .none:             return 0
            }
        }()
        
        let startOfWindow = due.adding(days: -windowInDays)
        
        return Date() >= startOfWindow
    }
}

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
        
        let calendar = Calendar.current
        let now = Date()
        
        if due < now {
            if isMedication {
                return "Missed Dose"
            }
            
            let days = calendar.dateComponents([.day], from: due, to: now).day ?? 0
            return "Overdue by \(days) days"
        }
        
        if calendar.isDateInToday(due) {
            return isMedication ? "Today at \(due.formatted(date: .omitted, time: .shortened))" : "Due Today"
        }
        
        if calendar.isDateInTomorrow(due) {
            return isMedication ? "Tomorrow at \(due.formatted(date: .omitted, time: .shortened))" : "Due Tomorrow"
        }
        
        let days = calendar.dateComponents([.day], from: now, to: due).day ?? 0
        return "In \(days) days"
    }
    
    var isUrgent: Bool {
        guard let due = nextDueDate, !isResolved else { return false }
        return due < Date()
    }
    
    func isPastEnd(currentDate: Date) -> Bool {
        guard let _ = durationDays, let _ = timesPerDay else { return false }
        return false
    }
    
    var isActionable: Bool {
        guard let due = nextDueDate else { return false }
        
        if due < Date() { return true }
        
        let calendar = Calendar.current
        
        if category == .medication {
            if let earlyAccessTime = calendar.date(byAdding: .minute, value: -30, to: due) {
                return Date() >= earlyAccessTime
            }
            return false
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
        
        guard let startOfWindow = calendar.date(byAdding: .day, value: -windowInDays, to: due) else {
            return false
        }
        
        return Date() >= startOfWindow
    }
}

//
//  MedicationScheduler.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 12.01.26.
//


import Foundation

struct MedicationScheduler {
    static func generateSchedule(start: Date, frequency: Int) -> [Date] {
        var times: [Date] = []
        let calendar = Calendar.current
        let intervalHours = 24 / max(1, frequency)
        
        for i in 0..<frequency {
            if let slot = calendar.date(byAdding: .hour, value: i * intervalHours, to: start) {
                times.append(slot)
            }
        }
        return times
    }
    
    static func findNextDose(from times: [Date]) -> Date? {
        let now = Date()
        for time in times {
            let timeToday = time.replaceDate(with: now)
            if timeToday > now { return timeToday }
        }
        if let first = times.first {
            let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: now) ?? now
            return first.replaceDate(with: tomorrow)
        }
        return nil
    }
}

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
        let intervalMinutes = Int((24.0 / Double(max(1, frequency))) * 60)
        
        for i in 0..<frequency {
            times.append(start.adding(minutes: i * intervalMinutes))
        }
        return times
    }
    
    static func findNextDose(from times: [Date]) -> Date? {
        let now = Date()
        
        for time in times {
            let timeToday = time.replaceDate(with: now)
            if timeToday.isInFuture {
                return timeToday
            }
        }
        
        if let first = times.first {
            let tomorrow = now.adding(days: 1)
            return first.replaceDate(with: tomorrow)
        }
        return nil
    }
}

//
//  MedicationScheduler.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 12.01.26.
//


import Foundation

struct MedicationScheduler {
    
    // MARK: - Methods
    
    static func generateSchedule(start: Date, frequency: Int) -> [Date] {
        let count = max(1, frequency)
        let intervalMinutes = Int((24.0 / Double(count)) * 60)
        
        var times: [Date] = []
        times.reserveCapacity(count)
        
        let calendar = Calendar.app
        let startComponents = calendar.dateComponents([.hour, .minute], from: start)
        let today = Date()
        
        guard let startToday = calendar.date(
            bySettingHour: startComponents.hour ?? 0,
            minute: startComponents.minute ?? 0,
            second: 0,
            of: today
        ) else {
            return []
        }
        
        for i in 0..<count {
            let t = startToday.adding(minutes: i * intervalMinutes)
            times.append(t)
        }
        
        return normalizeTimes(times)
    }
    
    static func findNextDose(from times: [Date], now: Date = Date()) -> Date? {
        
        let normalized = normalizeTimes(times)
        guard !normalized.isEmpty else { return nil }
        
        let calendar = Calendar.app
        
        let todayOccurrences: [Date] = normalized.compactMap { timeAnchor in
            let comps = calendar.dateComponents([.hour, .minute], from: timeAnchor)
            return calendar.date(
                bySettingHour: comps.hour ?? 0,
                minute: comps.minute ?? 0,
                second: 0,
                of: now
            )
        }.sorted()
        
        if let nextToday = todayOccurrences.first(where: { $0 > now }) {
            return nextToday
        }
        
        guard let firstAnchor = normalized.first else { return nil }
        let firstComps = calendar.dateComponents([.hour, .minute], from: firstAnchor)
        
        let tomorrow = now.adding(days: 1)
        return calendar.date(
            bySettingHour: firstComps.hour ?? 0,
            minute: firstComps.minute ?? 0,
            second: 0,
            of: tomorrow
        )
    }
    
    // MARK: - Private Helpers
    
    private static func normalizeTimes(_ times: [Date]) -> [Date] {
        let calendar = Calendar.app
        
        var seen = Set<String>()
        var unique: [Date] = []
        
        for t in times {
            let comps = calendar.dateComponents([.hour, .minute], from: t)
            let key = "\(comps.hour ?? 0):\(comps.minute ?? 0)"
            
            if !seen.contains(key) {
                seen.insert(key)
                unique.append(t)
            }
        }
        
        return unique.sorted { a, b in
            let ca = calendar.dateComponents([.hour, .minute], from: a)
            let cb = calendar.dateComponents([.hour, .minute], from: b)
            
            let ha = ca.hour ?? 0
            let hb = cb.hour ?? 0
            if ha != hb { return ha < hb }
            return (ca.minute ?? 0) < (cb.minute ?? 0)
        }
    }
}

// MARK: - Calendar Helper

private extension Calendar {
    static var app: Calendar {
        // Keep consistent with your Date extension’s Calendar.app (if you adopt my replacement).
        let cal = Calendar.current
        return cal
    }
}

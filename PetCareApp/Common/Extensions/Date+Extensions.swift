//
//  Date+Extensions.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 12.01.26.
//

import Foundation

extension Date {
    
    // MARK: - Boolean Checks
    
    var isToday: Bool {
        Calendar.app.isDateInToday(self)
    }
    
    var isTomorrow: Bool {
        Calendar.app.isDateInTomorrow(self)
    }
    
    var isYesterday: Bool {
        Calendar.app.isDateInYesterday(self)
    }
    
    var isInPast: Bool {
        self < Date()
    }
    
    var isInFuture: Bool {
        self > Date()
    }
    
    // MARK: - Manipulation
    
    var startOfDay: Date {
        Calendar.app.startOfDay(for: self)
    }
    
    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.app.date(byAdding: components, to: startOfDay) ?? self
    }
    
    func adding(minutes: Int) -> Date {
        Calendar.app.date(byAdding: .minute, value: minutes, to: self) ?? self
    }
    
    func adding(hours: Int) -> Date {
        Calendar.app.date(byAdding: .hour, value: hours, to: self) ?? self
    }
    
    func adding(days: Int) -> Date {
        Calendar.app.date(byAdding: .day, value: days, to: self) ?? self
    }
    
    func adding(months: Int) -> Date {
        Calendar.app.date(byAdding: .month, value: months, to: self) ?? self
    }
    
    func adding(years: Int) -> Date {
        Calendar.app.date(byAdding: .year, value: years, to: self) ?? self
    }
    
    func addingMonthsClamped(_ months: Int) -> Date {
        Calendar.app.addingMonthsClamped(from: self, months: months) ?? self
    }
    
    func addingYearsClamped(_ years: Int) -> Date {
        Calendar.app.addingYearsClamped(from: self, years: years) ?? self
    }
    
    func replaceDate(with otherDate: Date) -> Date {
        let calendar = Calendar.app
        let timeComponents = calendar.dateComponents(
            [.hour, .minute, .second],
            from: self
        )
        
        return calendar.date(
            bySettingHour: timeComponents.hour ?? 0,
            minute: timeComponents.minute ?? 0,
            second: timeComponents.second ?? 0,
            of: otherDate
        ) ?? otherDate
    }
    
    // MARK: - Formatting
    
    var timeString: String {
        formatted(Date.FormatStyle(date: .omitted, time: .shortened))
    }
    
    var shortDateString: String {
        formatted(.dateTime.day().month(.abbreviated))
    }
    
    var mediumDateString: String {
        formatted(.dateTime.year().month().day())
    }
    
    var monthAbbreviation: String {
        formatted(.dateTime.month(.abbreviated)).uppercased()
    }
    
    var dayNumber: String {
        formatted(.dateTime.day())
    }
    
    var yearNumber: String {
        formatted(.dateTime.year())
    }
    
    var relativeDayString: String {
        if isToday { return "Today" }
        if isYesterday { return "Yesterday" }
        if isTomorrow { return "Tomorrow" }
        return shortDateString
    }
    
    var relativeDateTimeString: String {
        "\(relativeDayString) at \(timeString)"
    }
    
    func ageDescription(to endDate: Date = Date()) -> String {
        let calendar = Calendar.app
        let components = calendar.dateComponents(
            [.year, .month],
            from: self,
            to: endDate
        )
        
        let years = components.year ?? 0
        let months = components.month ?? 0
        
        if years > 0 {
            return months > 0 ? "\(years)y \(months)m" : "\(years) years"
        } else {
            return "\(months) months"
        }
    }
}

// MARK: - Calendar Helpers

private extension Calendar {
    
    static var app: Calendar = {
        var cal = Calendar.current
        return cal
    }()
    
    func addingMonthsClamped(from date: Date, months: Int) -> Date?
    {
        let comps = dateComponents(
            [.year, .month, .day, .hour, .minute, .second],
            from: date
        )
        
        guard
            let year = comps.year,
            let month = comps.month,
            let day = comps.day
        else { return nil }
        
        var newMonth = month + months
        var newYear = year
        
        while newMonth > 12 {
            newMonth -= 12
            newYear += 1
        }
        while newMonth < 1 {
            newMonth += 12
            newYear -= 1
        }
        
        var monthStart = DateComponents()
        monthStart.year = newYear
        monthStart.month = newMonth
        monthStart.day = 1
        guard let startDate = self.date(from: monthStart),
              let range = self.range(of: .day, in: .month, for: startDate)
        else { return nil }
        
        let clampedDay = min(day, range.count)
        
        var result = DateComponents()
        result.year = newYear
        result.month = newMonth
        result.day = clampedDay
        result.hour = comps.hour
        result.minute = comps.minute
        result.second = comps.second
        
        return self.date(from: result)
    }
    
    func addingYearsClamped(from date: Date, years: Int) -> Date? {
        let comps = dateComponents(
            [.year, .month, .day, .hour, .minute, .second],
            from: date
        )
        
        guard
            let year = comps.year,
            let month = comps.month,
            let day = comps.day
        else { return nil }
        
        let newYear = year + years
        
        var monthStart = DateComponents()
        monthStart.year = newYear
        monthStart.month = month
        monthStart.day = 1
        
        guard let startDate = self.date(from: monthStart),
              let range = self.range(of: .day, in: .month, for: startDate)
        else { return nil }
        
        let clampedDay = min(day, range.count)
        
        var result = DateComponents()
        result.year = newYear
        result.month = month
        result.day = clampedDay
        result.hour = comps.hour
        result.minute = comps.minute
        result.second = comps.second
        
        return self.date(from: result)
    }
}

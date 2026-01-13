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
        Calendar.current.isDateInToday(self)
    }
    
    var isTomorrow: Bool {
        Calendar.current.isDateInTomorrow(self)
    }
    
    var isYesterday: Bool {
        Calendar.current.isDateInYesterday(self)
    }
    
    var isInPast: Bool {
        self < Date()
    }
    
    var isInFuture: Bool {
        self > Date()
    }
    
    // MARK: - Manipulation
    
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
    
    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay) ?? self
    }
    
    func adding(minutes: Int) -> Date {
        Calendar.current.date(byAdding: .minute, value: minutes, to: self) ?? self
    }
    
    func adding(hours: Int) -> Date {
        Calendar.current.date(byAdding: .hour, value: hours, to: self) ?? self
    }
    
    func adding(days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: days, to: self) ?? self
    }
    
    func adding(months: Int) -> Date {
        Calendar.current.date(byAdding: .month, value: months, to: self) ?? self
    }
    
    func adding(years: Int) -> Date {
        Calendar.current.date(byAdding: .year, value: years, to: self) ?? self
    }
    
    func replaceDate(with otherDate: Date) -> Date {
        let calendar = Calendar.current
        let timeComponents = calendar.dateComponents([.hour, .minute, .second], from: self)
        
        return calendar.date(
            bySettingHour: timeComponents.hour ?? 0,
            minute: timeComponents.minute ?? 0,
            second: timeComponents.second ?? 0,
            of: otherDate
        ) ?? otherDate
    }
    
    // MARK: - Formatting
    
    var timeString: String {
        DateFormats.time.string(from: self)
    }
    
    var shortDateString: String {
        DateFormats.shortDate.string(from: self)
    }
    
    var mediumDateString: String {
        DateFormats.mediumDate.string(from: self)
    }
    
    var monthAbbreviation: String {
        DateFormats.monthAbbr.string(from: self).uppercased()
    }
    
    var dayNumber: String {
        DateFormats.dayNum.string(from: self)
    }
    
    var yearNumber: String {
        DateFormats.yearNumber.string(from: self)
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
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: self, to: endDate)
        
        let years = components.year ?? 0
        let months = components.month ?? 0
        
        if years > 0 {
            return months > 0 ? "\(years)y \(months)m" : "\(years) years"
        } else {
            return "\(months) months"
        }
    }
}

// MARK: - Formatters

fileprivate struct DateFormats {
    static let time: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()
    
    static let shortDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("dMMM")
        return formatter
    }()
    
    static let mediumDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
    
    static let monthAbbr: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        return formatter
    }()
    
    static let dayNum: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }()
    
    static let yearNumber: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter
    }()
}

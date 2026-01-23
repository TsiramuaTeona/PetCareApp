//
//  DateFactory.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 23.01.26.
//

import Foundation

enum DateFactory {
    static func make(
        year: Int,
        month: Int,
        day: Int,
        hour: Int = 0,
        minute: Int = 0,
        second: Int = 0,
        calendar: Calendar = .current
    ) -> Date {
        let calendar = calendar
        let timeZone = calendar.timeZone

        var components = DateComponents()
        components.calendar = calendar
        components.timeZone = timeZone
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        components.minute = minute
        components.second = second

        guard let date = calendar.date(from: components) else {
            preconditionFailure("Invalid date components: \(components)")
        }
        
        return date
    }

    static func hourMinute(_ date: Date, calendar: Calendar = .current) -> (hour: Int, minute: Int) {
        let calendar = calendar.dateComponents([.hour, .minute], from: date)
        return (calendar.hour ?? 0, calendar.minute ?? 0)
    }

    static func yearMonthDay(_ date: Date, calendar: Calendar = .current) -> (year: Int, month: Int, day: Int) {
        let calendar = calendar.dateComponents([.year, .month, .day], from: date)
        return (calendar.year ?? 0, calendar.month ?? 0, calendar.day ?? 0)
    }
}

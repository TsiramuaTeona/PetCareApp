//
//  Date+Extensions.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 12.01.26.
//


import Foundation

extension Date {
    func replaceDate(with otherDate: Date) -> Date {
        let calendar = Calendar.current
        let timeComponents = calendar.dateComponents([.hour, .minute], from: self)
        
        return calendar.date(
            bySettingHour: timeComponents.hour ?? 0,
            minute: timeComponents.minute ?? 0,
            second: 0,
            of: otherDate
        ) ?? otherDate
    }
}

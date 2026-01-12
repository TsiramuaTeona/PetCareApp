//
//  RecurrenceRule.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 12.01.26.
//


import Foundation

enum RecurrenceRule: String, Codable, CaseIterable, Identifiable {
    case none = "None"
    case daily = "Daily"
    case weekly = "Weekly"
    case monthly = "Monthly"
    case everyThreeMonths = "Every 3 Months"
    case everySixMonths = "Every 6 Months"
    case yearly = "Yearly"
    
    var id: String { rawValue }
}

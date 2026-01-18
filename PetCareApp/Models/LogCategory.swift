//
//  LogCategory.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 12.01.26.
//

import SwiftUI

enum LogCategory: String, Codable, CaseIterable, Identifiable {
    case vaccine = "Vaccine"
    case medication = "Medication"
    case parasite = "Parasite Control"
    case weight = "Weight"
    case food = "Nutrition"
    case grooming = "Grooming"
    case vet = "Vet Visit"
    case other = "Other"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .vaccine: return "syringe.fill"
        case .medication: return "pills.fill"
        case .parasite: return "ant.fill"
        case .weight: return "scalemass.fill"
        case .food: return "fork.knife"
        case .grooming: return "scissors"
        case .vet: return "cross.case.fill"
        case .other: return "doc.text.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .vaccine:
            return .brandSecondary
        case .medication:
            return .brandPurple
        case .parasite:
            return .brandOrange
        case .weight:
            return .brandTeal
        case .food:
            return .brandGreen
        case .grooming:
            return .brandPink
        case .vet:
            return .brandPrimary
        case .other:
            return .success
        }
    }
}

extension LogCategory {
    
    var hasValueField: Bool {
        self == .weight
    }
    
    var titlePlaceholder: String {
        switch self {
        case .vet: return "Clinic or Reason"
        case .food: return "Food Brand / Type"
        case .grooming: return "Salon or Service"
        default: return "Title"
        }
    }
    
    var titleSuggestions: [String] {
        switch self {
        case .vaccine: return ["Rabies", "Distemper", "Parvovirus", "Bordetella"]
        case .parasite: return ["Heartworm", "Flea & Tick", "Simparica Trio", "NexGard"]
        case .grooming: return ["Bath", "Nail Trim", "Haircut", "Ear Cleaning"]
        case .vet: return ["Annual Checkup", "Emergency", "Dental Cleaning", "Vaccination Visit"]
        case .food: return ["Kibble", "Wet Food", "Treats", "Diet Change"]
        default: return []
        }
    }
    
    func reminderLabel(isHistory: Bool) -> String {
        guard isHistory else { return "Set Repetition" }
        switch self {
        case .vet: return "Schedule Next Visit"
        case .grooming: return "Schedule Next Appointment"
        case .food: return "Remind Next"
        case .vaccine, .parasite, .medication: return "Schedule Next Dose"
        default: return "Add Follow-up Reminder"
        }
    }
}

//
//  HealthLog.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 05.01.26.
//

import Foundation
import FirebaseFirestore

struct HealthLog: Codable, Identifiable {
    @DocumentID var id: String?
    var petId: String
    var category: LogCategory
    var title: String          // e.g., "Rabies", "25.4 kg", "Simparica Trio"
    var note: String?          // e.g., "Next dose in 1 month"
    var date: Date             // Date it happened
    var nextDueDate: Date?     // (Optional) When is it due again?
    var value: Double?         // (Optional) For weight or dosage amount
}

enum LogCategory: String, Codable, CaseIterable {
    case vaccine = "Vaccine"
    case medication = "Medication"
    case weight = "Weight"
    case food = "Nutrition"
    case grooming = "Grooming"
    case vet = "Vet Visit"
    
    var icon: String {
        switch self {
        case .vaccine: return "syringe"
        case .medication: return "pills"
        case .weight: return "scalemass"
        case .food: return "carrot"
        case .grooming: return "scissors"
        case .vet: return "cross.case"
        }
    }
    
    var colorName: String {
        switch self {
        case .vaccine, .medication: return "BrandSecondary"
        case .weight, .food: return "BrandPrimary"
        default: return "TextSecondary"
        }
    }
}

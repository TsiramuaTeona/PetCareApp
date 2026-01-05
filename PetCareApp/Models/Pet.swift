//
//  Pet.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 03.01.26.
//


import Foundation
import FirebaseFirestore

struct Pet: Codable, Identifiable {
    @DocumentID var id: String?
    let householdId: String
    
    let name: String
    let species: PetSpecies
    let breed: String?
    let gender: PetGender
    
    let birthDate: Date
    let photoUrl: String?
    
    let createdAt: Date
    
    var ageFormatted: String {
        let components = Calendar.current.dateComponents([.year, .month], from: birthDate, to: Date())
        if let years = components.year, years > 0 {
            return "\(years) yrs"
        } else {
            return "\(components.month ?? 0) mos"
        }
    }
}

enum PetSpecies: String, Codable, CaseIterable, Identifiable {
    case dog = "Dog"
    case cat = "Cat"
    case other = "Other"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .dog: return "dog.fill"
        case .cat: return "cat.fill"
        case .other: return "pawprint.fill"
        }
    }
}

enum PetGender: String, Codable, CaseIterable {
    case male = "Male"
    case female = "Female"
}

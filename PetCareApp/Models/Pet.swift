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
    
    var name: String
    let species: PetSpecies
    var breed: String?
    let gender: PetGender
    
    let birthDate: Date
    var photoUrl: String?
    
    var color: String? 
    var bio: String?
    
    let createdAt: Date
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

extension Pet {
    var ageFormatted: String {
        let components = Calendar.current.dateComponents([.year, .month], from: birthDate, to: Date())
        if let years = components.year, years > 0 {
            return "\(years) yrs"
        } else {
            return "\(components.month ?? 0) mos"
        }
    }
    
    var displayBreed: String {
        breed?.isEmpty == false ? breed! : "Unknown Breed"
    }
    
    var displayGenderSymbol: String {
        gender == .female ? "♀" : "♂"
    }
    
    var genderColor: String {
        switch gender {
        case .male: return "BrandSecondary"
        case .female: return "BrandPrimary"
        }
    }
    
    var displayColor: String {
        color?.isEmpty == false ? color! : "-"
    }
    
    var displayBio: String {
        bio?.isEmpty == false ? bio! : "No bio yet. Tap edit to add one!"
    }
}

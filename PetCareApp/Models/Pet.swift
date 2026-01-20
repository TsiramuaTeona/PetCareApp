//
//  Pet.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 03.01.26.
//

import FirebaseFirestore
import Foundation

struct Pet: Codable, Identifiable, Equatable {
    @DocumentID var id: String?
    let householdId: String
    
    var name: String
    var species: PetSpecies
    var breed: String?
    var gender: PetGender
    
    var birthDate: Date
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
        birthDate.ageDescription()
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

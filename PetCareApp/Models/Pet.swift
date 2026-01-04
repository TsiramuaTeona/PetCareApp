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
    var name: String
    var species: String
    var breed: String?
    var dateOfBirth: Date
    var householdId: String
    var photoUrl: String?
    
    var ageFormatted: String {
        let components = Calendar.current.dateComponents([.year, .month], from: dateOfBirth, to: Date())
        if let years = components.year, years > 0 {
            return "\(years) yrs"
        } else {
            return "\(components.month ?? 0) mos"
        }
    }
}

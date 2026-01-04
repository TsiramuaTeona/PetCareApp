//
//  Household.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 04.01.26.
//


import Foundation
import FirebaseFirestore

struct Household: Codable, Identifiable {
    @DocumentID var id: String?
    var name: String
    var joinCode: String
    var adminId: String
    var memberIds: [String] 
    let createdAt: Date
}

//
//  UserProfile.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 04.01.26.
//


import Foundation

struct UserProfile: Codable, Identifiable {
    let id: String
    let email: String
    var fullName: String?
    var householdId: String? 
    let createdAt: Date
}

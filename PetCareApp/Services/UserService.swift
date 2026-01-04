//
//  UserService.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 04.01.26.
//


import FirebaseFirestore

protocol UserServiceProtocol {
    func createUserProfile(user: UserProfile) async throws
    func getUser(userId: String) async throws -> UserProfile
    func updateUserHousehold(userId: String, householdId: String) async throws
}

final class UserService: UserServiceProtocol {
    
    private let db = Firestore.firestore()
    
    func createUserProfile(user: UserProfile) async throws {
        try db.collection("users").document(user.id).setData(from: user)
    }
    
    func getUser(userId: String) async throws -> UserProfile {
        let snapshot = try await db.collection("users").document(userId).getDocument()
        return try snapshot.data(as: UserProfile.self)
    }
    
    func updateUserHousehold(userId: String, householdId: String) async throws {
        try await db.collection("users").document(userId).updateData([
            "householdId": householdId
        ])
    }
}

//
//  UserService.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 04.01.26.
//


import FirebaseFirestore

// MARK: - UserServiceProtocol

protocol UserServiceProtocol {
    func createUserProfile(user: UserProfile) async throws
    func getUser(userId: String) async throws -> UserProfile
    func updateUserHousehold(userId: String, householdId: String?) async throws
}

// MARK: - UserService

final class UserService: UserServiceProtocol {
    // MARK: - Properties
    
    private let db = Firestore.firestore()
    
    // MARK: - Methods
    
    func createUserProfile(user: UserProfile) async throws {
        try db.collection("users").document(user.id).setData(from: user)
    }
    
    func getUser(userId: String) async throws -> UserProfile {
        let snapshot = try await db.collection("users").document(userId).getDocument()
        return try snapshot.data(as: UserProfile.self)
    }
    
    func updateUserHousehold(userId: String, householdId: String?) async throws {
        let data: [String: Any] = [
            "householdId": householdId ?? FieldValue.delete()
        ]
        
        try await db.collection("users").document(userId).updateData(data)
    }
}

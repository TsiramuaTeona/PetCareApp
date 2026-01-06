//
//  HouseholdService.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 03.01.26.
//


import FirebaseFirestore

protocol HouseholdServiceProtocol {
    func createHousehold(name: String, adminId: String) async throws -> Household
    func joinHousehold(code: String, userId: String) async throws -> Household
    func getHousehold(id: String) async throws -> Household
    func leaveHousehold(id: String, userId: String) async throws
}

final class HouseholdService: HouseholdServiceProtocol {
    
    private let db = Firestore.firestore()
    
    func createHousehold(name: String, adminId: String) async throws -> Household {
        let batch = db.batch()
        
        let householdRef = db.collection("households").document()
        let joinCode = generateJoinCode()
        let newHouseholdId = householdRef.documentID
        
        let household = Household(
            id: nil,
            name: name,
            joinCode: joinCode,
            adminId: adminId,
            memberIds: [adminId],
            createdAt: Date()
        )
        
        try batch.setData(from: household, forDocument: householdRef)
        
        let userRef = db.collection("users").document(adminId)
        batch.updateData(["householdId": newHouseholdId], forDocument: userRef)
        
        try await batch.commit()
        
        return household
    }
    
    func joinHousehold(code: String, userId: String) async throws -> Household {
        let querySnapshot = try await db.collection("households")
            .whereField("joinCode", isEqualTo: code)
            .getDocuments()
        
        guard let document = querySnapshot.documents.first else {
            throw AuthError.unknown("Invalid join code")
        }
        
        let householdRef = document.reference
        let householdId = document.documentID
        let batch = db.batch()
        
        batch.updateData(["memberIds": FieldValue.arrayUnion([userId])], forDocument: householdRef)
        
        let userRef = db.collection("users").document(userId)
        batch.updateData(["householdId": householdId], forDocument: userRef)
        
        try await batch.commit()
        
        return try document.data(as: Household.self)
    }
    
    func getHousehold(id: String) async throws -> Household {
        let snapshot = try await db.collection("households").document(id).getDocument()
        return try snapshot.data(as: Household.self)
    }
    
    func leaveHousehold(id: String, userId: String) async throws {
        let batch = db.batch()
        
        let householdRef = db.collection("households").document(id)
        batch.updateData(["memberIds": FieldValue.arrayRemove([userId])], forDocument: householdRef)
        
        let userRef = db.collection("users").document(userId)
        batch.updateData(["householdId": FieldValue.delete()], forDocument: userRef)
        
        try await batch.commit()
    }
    
    private func generateJoinCode() -> String {
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<6).map { _ in letters.randomElement()! })
    }
}

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
}

final class HouseholdService: HouseholdServiceProtocol {
    
    private let db = Firestore.firestore()
    
    func createHousehold(name: String, adminId: String) async throws -> Household {
        let joinCode = generateJoinCode()
        
        let household = Household(
            id: nil,
            name: name,
            joinCode: joinCode,
            adminId: adminId,
            memberIds: [adminId],
            createdAt: Date()
        )
        
        let ref = try db.collection("households").addDocument(from: household)
        
        var savedHousehold = household
        savedHousehold.id = ref.documentID
        return savedHousehold
    }
    
    func joinHousehold(code: String, userId: String) async throws -> Household {
        let querySnapshot = try await db.collection("households")
            .whereField("joinCode", isEqualTo: code)
            .getDocuments()
        
        guard let document = querySnapshot.documents.first else {
            throw AuthError.unknown("Invalid join code")
        }
        
        let householdRef = document.reference
        try await householdRef.updateData([
            "memberIds": FieldValue.arrayUnion([userId])
        ])
        
        return try document.data(as: Household.self)
    }
    
    private func generateJoinCode() -> String {
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<6).map { _ in letters.randomElement()! })
    }
}

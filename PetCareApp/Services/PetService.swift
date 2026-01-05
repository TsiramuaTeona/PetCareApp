//
//  PetService.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 03.01.26.
//


import FirebaseFirestore

protocol PetServiceProtocol {
    func addPet(_ pet: Pet) async throws -> String
    func updatePetPhoto(petId: String, photoUrl: String) async throws
    func getPets(forHousehold householdId: String) async throws -> [Pet]
    func updatePet(_ pet: Pet) async throws
    func deletePet(petId: String) async throws
}

final class PetService: PetServiceProtocol {
    private let db = Firestore.firestore()
    private let collection = "pets"
    
    func addPet(_ pet: Pet) async throws -> String  {
        let ref = db.collection(collection).document()
        try ref.setData(from: pet)
        return ref.documentID
    }
    
    func updatePetPhoto(petId: String, photoUrl: String) async throws {
        try await db.collection(collection).document(petId).updateData([
            "photoUrl": photoUrl
        ])
    }
    
    func getPets(forHousehold householdId: String) async throws -> [Pet] {
        let snapshot = try await db.collection(collection)
            .whereField("householdId", isEqualTo: householdId)
            .getDocuments()
        
        return snapshot.documents.compactMap { try? $0.data(as: Pet.self) }
    }
    
    func updatePet(_ pet: Pet) async throws {
        guard let id = pet.id else { return }
        try db.collection(collection).document(id).setData(from: pet, merge: true)
    }
    
    func deletePet(petId: String) async throws {
        try await db.collection(collection).document(petId).delete()
    }
}

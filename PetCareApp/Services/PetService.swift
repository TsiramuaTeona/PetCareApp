//
//  PetService.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 03.01.26.
//


protocol PetServiceProtocol {
    func fetchPets(householdId: String) async throws -> [Pet]
    func deletePet(_ petId: String) async throws
}

final class PetService: PetServiceProtocol {
    func fetchPets(householdId: String) async throws -> [Pet] {
        //TODO: Implement actual network call to fetch pets
        
        return [
            Pet(id: "1", name: "Buddy"),
            Pet(id: "2", name: "Mittens")
        ]
    }
    
    func deletePet(_ petId: String) async throws {
        //TODO: Implement actual network call to delete pet
    }
}

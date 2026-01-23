//
//  PetServiceMock.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 23.01.26.
//

import Foundation
@testable import PetCareApp

final class PetServiceMock: PetServiceProtocol {
    
    // MARK: - Properties

    var petsByHouseholdId: [String: [Pet]] = [:]
    var petsById: [String: Pet] = [:]

    var addError: Error?
    var updatePhotoError: Error?
    var getPetsError: Error?
    var getPetError: Error?
    var updateError: Error?
    var deleteError: Error?

    private(set) var addCalls: [Pet] = []
    private(set) var updatePhotoCalls: [(petId: String, url: String)] = []
    private(set) var getPetsCalls: [String] = []
    private(set) var getPetCalls: [String] = []
    private(set) var updateCalls: [Pet] = []
    private(set) var deleteCalls: [String] = []

    // MARK: - Methods
    
    func addPet(_ pet: Pet) async throws -> String {
        addCalls.append(pet)
        if let addError { throw addError }

        let id = UUID().uuidString
        var new = pet
        new.id = id

        petsById[id] = new
        petsByHouseholdId[pet.householdId, default: []].append(new)
        return id
    }

    func updatePetPhoto(petId: String, photoUrl: String) async throws {
        updatePhotoCalls.append((petId, photoUrl))
        if let updatePhotoError { throw updatePhotoError }
        var pet = petsById[petId]
        pet?.photoUrl = photoUrl
        if let pet { petsById[petId] = pet }
    }

    func getPets(forHousehold householdId: String) async throws -> [Pet] {
        getPetsCalls.append(householdId)
        if let getPetsError { throw getPetsError }
        return petsByHouseholdId[householdId] ?? []
    }

    func getPet(petId: String) async throws -> Pet {
        getPetCalls.append(petId)
        if let getPetError { throw getPetError }
        
        guard let pet = petsById[petId] else {
            throw TestError.message("PetServiceMock missing petId=\(petId)")
        }
        return pet
    }

    func updatePet(_ pet: Pet) async throws {
        updateCalls.append(pet)
        if let updateError { throw updateError }
        guard let id = pet.id else { return }
        petsById[id] = pet
    }

    func deletePet(petId: String) async throws {
        deleteCalls.append(petId)
        if let deleteError { throw deleteError }
        petsById.removeValue(forKey: petId)
        for key in petsByHouseholdId.keys {
            petsByHouseholdId[key]?.removeAll { $0.id == petId }
        }
    }
}

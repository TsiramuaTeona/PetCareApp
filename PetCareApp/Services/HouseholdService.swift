//
//  HouseholdService.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 03.01.26.
//


protocol HouseholdServiceProtocol {
    func createHousehold(for userId: String) async throws -> String
    func joinHousehold(code: String, userId: String) async throws
    func fetchHouseholdId(for userId: String) async throws -> String
}

final class HouseholdService: HouseholdServiceProtocol {
    func createHousehold(for userId: String) async throws -> String {
        //TODO: Implement network call to create a household
        return "new-household-id"
    }
    
    func joinHousehold(code: String, userId: String) async throws {
        //TODO: Implement network call to join a household using the provided code
    }
    
    func fetchHouseholdId(for userId: String) async throws -> String {
        //TODO: Implement network call to fetch the household ID for the user
        return "existing-household-id"
    }
}

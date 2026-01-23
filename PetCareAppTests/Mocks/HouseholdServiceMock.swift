//
//  HouseholdServiceMock.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 23.01.26.
//

import Foundation
@testable import PetCareApp

final class HouseholdServiceMock: HouseholdServiceProtocol {
    
    // MARK: - Properties
    
    var createResult: Household?
    var joinResult: Household?
    var getResult: Household?
    
    var createError: Error?
    var joinError: Error?
    var getError: Error?
    var leaveError: Error?
    
    private(set) var createCalls: [(name: String, adminId: String)] = []
    private(set) var joinCalls: [(code: String, userId: String)] = []
    private(set) var getCalls: [String] = []
    private(set) var leaveCalls: [(id: String, userId: String)] = []
    
    // MARK: - Methods
    
    func createHousehold(name: String, adminId: String) async throws -> Household {
        createCalls.append((name, adminId))
        if let createError { throw createError }
        
        guard let result = createResult else {
            throw TestError.message("HouseholdServiceMock.createResult not set")
        }
        return result
    }
    
    func joinHousehold(code: String, userId: String) async throws -> Household {
        joinCalls.append((code, userId))
        if let joinError { throw joinError }
        
        guard let result = joinResult else {
            throw TestError.message("HouseholdServiceMock.joinResult not set")
        }
        return result
    }
    
    func getHousehold(id: String) async throws -> Household {
        getCalls.append(id)
        if let getError { throw getError }
        
        guard let result = getResult else {
            throw TestError.message("HouseholdServiceMock.getResult not set")
        }
        return result
    }
    
    func leaveHousehold(id: String, userId: String) async throws {
        leaveCalls.append((id, userId))
        if let leaveError { throw leaveError }
    }
}

//
//  HealthServiceMock.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 23.01.26.
//

import Foundation
@testable import PetCareApp

final class HealthServiceMock: HealthServiceProtocol {
    
    // MARK: - Properties

    var logsByPetId: [String: [HealthLog]] = [:]

    var addLogError: Error?
    var fetchLogsError: Error?
    var updateLogError: Error?
    var deleteLogError: Error?
    var deleteAllLogsError: Error?

    private(set) var addCalls: [HealthLog] = []
    private(set) var fetchCalls: [String] = []
    private(set) var updateCalls: [HealthLog] = []
    private(set) var deleteCalls: [(petId: String, logId: String)] = []
    private(set) var deleteAllCalls: [String] = []

    // MARK: - Methods
    
    func addLog(_ log: HealthLog) async throws -> String {
        addCalls.append(log)
        if let addLogError { throw addLogError }

        let id = UUID().uuidString
        var new = log
        new.id = id
        logsByPetId[log.petId, default: []].insert(new, at: 0)
        return id
    }

    func fetchLogs(petId: String) async throws -> [HealthLog] {
        fetchCalls.append(petId)
        if let fetchLogsError { throw fetchLogsError }
        return logsByPetId[petId] ?? []
    }

    func updateLog(_ log: HealthLog) async throws {
        updateCalls.append(log)
        if let updateLogError { throw updateLogError }
        guard let id = log.id else { return }

        var arr = logsByPetId[log.petId] ?? []
        if let idx = arr.firstIndex(where: { $0.id == id }) {
            arr[idx] = log
            logsByPetId[log.petId] = arr
        }
    }

    func deleteLog(petId: String, logId: String) async throws {
        deleteCalls.append((petId, logId))
        if let deleteLogError { throw deleteLogError }

        var arr = logsByPetId[petId] ?? []
        arr.removeAll { $0.id == logId }
        logsByPetId[petId] = arr
    }

    func deleteAllLogs(petId: String) async throws {
        deleteAllCalls.append(petId)
        if let deleteAllLogsError { throw deleteAllLogsError }
        logsByPetId[petId] = []
    }
}

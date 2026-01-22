//
//  HealthService.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 10.01.26.
//

import FirebaseFirestore
import os

// MARK: - HealthServiceProtocol

protocol HealthServiceProtocol {
    func addLog(_ log: HealthLog) async throws -> String
    func fetchLogs(petId: String) async throws -> [HealthLog]
    func updateLog(_ log: HealthLog) async throws
    func deleteLog(petId: String, logId: String) async throws
    func deleteAllLogs(petId: String) async throws
}

// MARK: - HealthService

final class HealthService: HealthServiceProtocol {
    // MARK: - Properties
    
    private let db = Firestore.firestore()
    private let collection = "healthLogs"
    
    // MARK: - Methods
    
    func addLog(_ log: HealthLog) async throws -> String {
        let ref =
        db
            .collection("pets")
            .document(log.petId)
            .collection(collection)
            .document()
        
        try ref.setData(from: log)
        return ref.documentID
    }
    
    func fetchLogs(petId: String) async throws -> [HealthLog] {
        let snapshot = try await db
            .collection("pets")
            .document(petId)
            .collection(collection)
            .order(by: "date", descending: true)
            .getDocuments()
        
        var result: [HealthLog] = []
        result.reserveCapacity(snapshot.documents.count)
        
        for doc in snapshot.documents {
            do {
                let log = try doc.data(as: HealthLog.self)
                result.append(log)
            } catch {
                AppLogger.firestore.error(
                    "Failed to decode HealthLog. petId=\(petId, privacy: .public) docId=\(doc.documentID, privacy: .public) error=\(String(describing: error), privacy: .public)"
                )
            }
        }
        
        return result
    }
    
    func updateLog(_ log: HealthLog) async throws {
        guard let logId = log.id else { return }
        
        try db
            .collection("pets")
            .document(log.petId)
            .collection(collection)
            .document(logId)
            .setData(from: log, merge: true)
    }
    
    func deleteLog(petId: String, logId: String) async throws {
        try await db
            .collection("pets")
            .document(petId)
            .collection(collection)
            .document(logId).delete()
    }
    
    func deleteAllLogs(petId: String) async throws {
        let logsRef = db
            .collection("pets")
            .document(petId)
            .collection(collection)
        
        let snapshot = try await logsRef.getDocuments()
        
        let batch = db.batch()
        for doc in snapshot.documents {
            batch.deleteDocument(doc.reference)
        }
        
        try await batch.commit()
    }
}

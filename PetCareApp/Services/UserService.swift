//
//  UserService.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 04.01.26.
//


import FirebaseFirestore
import Combine

// MARK: - UserServiceError

enum UserServiceError: LocalizedError {
    case userDocumentMissing(userId: String)
    
    var errorDescription: String? {
        switch self {
        case .userDocumentMissing(let id):
            return "User profile document is missing for uid: \(id)"
        }
    }
}

// MARK: - UserServiceProtocol

protocol UserServiceProtocol {
    func createUserProfile(user: UserProfile) async throws
    func getUser(userId: String) async throws -> UserProfile
    func updateUserHousehold(userId: String, householdId: String?) async throws
    func householdIdPublisher(userId: String) -> AnyPublisher<String?, Never>
}

// MARK: - UserService

final class UserService: UserServiceProtocol {
    // MARK: - Properties
    
    private let db = Firestore.firestore()
    
    // MARK: - Methods
    
    func createUserProfile(user: UserProfile) async throws {
        try db.collection("users")
            .document(user.id)
            .setData(from: user, merge: true)
    }
    
    func getUser(userId: String) async throws -> UserProfile {
        let snapshot = try await db.collection("users").document(userId).getDocument()
        
        guard snapshot.exists else {
            throw UserServiceError.userDocumentMissing(userId: userId)
        }
        
        return try snapshot.data(as: UserProfile.self)
    }
    
    func updateUserHousehold(userId: String, householdId: String?) async throws {
        let data: [String: Any] = [
            "householdId": householdId?.isEmptyOrWhitespace == false
            ? householdId as Any
            : FieldValue.delete()
        ]
        
        try await db.collection("users").document(userId).updateData(data)
    }
    
    func householdIdPublisher(userId: String) -> AnyPublisher<String?, Never> {
        let subject = CurrentValueSubject<String?, Never>(nil)
        
        let reg = db.collection("users").document(userId)
            .addSnapshotListener { snapshot, _ in
                guard let snapshot else {
                    subject.send(nil)
                    return
                }
                
                let householdId = snapshot.get("householdId") as? String
                let cleaned = householdId?.trimmingCharacters(in: .whitespacesAndNewlines)
                subject.send(cleaned?.isEmpty == false ? cleaned : nil)
            }
        
        return subject
            .removeDuplicates()
            .handleEvents(receiveCancel: {
                reg.remove()
            })
            .eraseToAnyPublisher()
    }
}

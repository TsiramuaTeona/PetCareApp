//
//  ImageStorageService.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 08.01.26.
//


import Foundation
import FirebaseStorage

// MARK: - ImageStorageServiceProtocol

protocol ImageStorageServiceProtocol {
    func uploadPetImage(petId: String, data: Data) async throws -> String
    func uploadUserProfileImage(userId: String, data: Data) async throws -> String
}

// MARK: - ImageStorageService

final class ImageStorageService: ImageStorageServiceProtocol {

    // MARK: - Properties
    
    private let storage = Storage.storage().reference()

    // MARK: - Methods
    
    private func uploadImage(path: String, imageData: Data) async throws -> String {
        let ref = storage.child(path).child("\(UUID().uuidString).jpg")

        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"

        _ = try await ref.putDataAsync(imageData, metadata: metadata)

        let url = try await ref.downloadURL()
        return url.absoluteString
    }
    
    func uploadPetImage(petId: String, data: Data) async throws -> String {
        try await uploadImage(
            path: "pets/\(petId)",
            imageData: data
        )
    }
    
    func uploadUserProfileImage(userId: String, data: Data) async throws -> String {
        try await uploadImage(
            path: "users/\(userId)",
            imageData: data
        )
    }
}

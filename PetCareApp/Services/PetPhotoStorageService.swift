//
//  PetPhotoStorageService.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 05.01.26.
//


import Foundation
import FirebaseStorage
import FirebaseAuth

protocol PetPhotoStorageServiceProtocol {
    func uploadPetPhoto(
        petId: String,
        imageData: Data
    ) async throws -> String
}

final class PetPhotoStorageService: PetPhotoStorageServiceProtocol {
    
    private let storage = Storage.storage().reference()
    
    func uploadPetPhoto(petId: String, imageData: Data) async throws -> String {
        let ref = storage
            .child("petPhotos")
            .child(petId)
            .child("profile.jpg")
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        _ = try await ref.putDataAsync(imageData, metadata: metadata)
        
        let url = try await ref.downloadURL()
        return url.absoluteString
    }
}

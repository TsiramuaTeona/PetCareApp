//
//  ImageStorageServiceMock.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 23.01.26.
//

import Foundation
@testable import PetCareApp

final class ImageStorageServiceMock: ImageStorageServiceProtocol {
    
    // MARK: - Properties

    var uploadPetImageResult: String = "https://example.com/pet.jpg"
    var uploadUserImageResult: String = "https://example.com/user.jpg"

    var uploadPetImageError: Error?
    var uploadUserImageError: Error?

    private(set) var uploadPetCalls: [(petId: String, size: Int)] = []
    private(set) var uploadUserCalls: [(userId: String, size: Int)] = []

    // MARK: - Methods
    
    func uploadPetImage(petId: String, data: Data) async throws -> String {
        uploadPetCalls.append((petId, data.count))
        if let uploadPetImageError { throw uploadPetImageError }
        return uploadPetImageResult
    }

    func uploadUserProfileImage(userId: String, data: Data) async throws -> String {
        uploadUserCalls.append((userId, data.count))
        if let uploadUserImageError { throw uploadUserImageError }
        return uploadUserImageResult
    }
}

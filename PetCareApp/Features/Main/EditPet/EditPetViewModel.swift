//
//  EditPetViewModel.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 08.01.26.
//


import SwiftUI
import Combine

@MainActor
final class EditPetViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published var name: String
    @Published var species: PetSpecies
    @Published var breed: String
    @Published var gender: PetGender
    @Published var birthDate: Date
    
    @Published var color: String
    @Published var bio: String
    @Published var photoData: Data?
    
    @Published private(set) var state: ScreenState = .loaded
    
    // MARK: - Private Properties
    
    private let originalPet: Pet
    private let petService: PetServiceProtocol
    private let imageStorageService: ImageStorageServiceProtocol
    
    // MARK: - Computed Properties
    
    var currentPhotoUrl: String? {
        originalPet.photoUrl
    }
    
    // MARK: - Initializer
    
    init(
        pet: Pet,
        petService: PetServiceProtocol,
        imageStorageService: ImageStorageServiceProtocol
    ) {
        self.originalPet = pet
        self.petService = petService
        self.imageStorageService = imageStorageService
        
        self.name = pet.name
        self.species = pet.species
        self.breed = pet.breed ?? ""
        self.gender = pet.gender
        self.birthDate = pet.birthDate
        self.color = pet.color ?? ""
        self.bio = pet.bio ?? ""
    }
    
    // MARK: - Methods
    
    func save() async -> Pet? {
        guard let petId = originalPet.id else { return nil }
        
        state = .loading
        
        var updatedPet = originalPet
        updatedPet.name = name.trimmed
        updatedPet.species = species
        updatedPet.breed = breed.nilIfEmpty
        updatedPet.gender = gender
        updatedPet.birthDate = birthDate
        updatedPet.color = color.nilIfEmpty
        updatedPet.bio = bio
        
        do {
            try await petService.updatePet(updatedPet)
            
            if let photoData {
                let url = try await imageStorageService.uploadPetImage(
                    petId: petId,
                    data: photoData
                )
                updatedPet.photoUrl = url
                try await petService.updatePetPhoto(
                    petId: petId,
                    photoUrl: url
                )
            }
            
            state = .loaded
            return updatedPet
            
        } catch {
            state = .error(error.localizedDescription)
            return nil
        }
    }
}

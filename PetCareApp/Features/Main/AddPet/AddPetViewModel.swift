//
//  AddPetViewModel.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 05.01.26.
//


import Foundation
import Combine

@MainActor
final class AddPetViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var photoData: Data?
    
    @Published var name: String = ""
    @Published var species: PetSpecies = .dog
    @Published var breed: String = ""
    @Published var birthDate: Date = Date()
    @Published var weight: String = ""
    @Published var gender: PetGender = .male
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var shouldDismiss = false
    
    // MARK: - Private Properties
    
    private let householdId: String
    private let petService: PetServiceProtocol
    private let imageStorageService: ImageStorageServiceProtocol
    
    // MARK: - Initializer
    
    init(
        householdId: String,
        petService: PetServiceProtocol,
        imageStorageService: ImageStorageServiceProtocol
    ) {
        self.householdId = householdId
        self.petService = petService
        self.imageStorageService = imageStorageService
    }
    
    // MARK: - Methods
    
    func savePet() async {
        errorMessage = nil
        
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "Please enter a name."
            return
        }
        
        isLoading = true
        
        var createdPetId: String?
        
        do {
            let pet = Pet(
                id: nil,
                householdId: householdId,
                name: name,
                species: species,
                breed: breed.isEmpty ? nil : breed,
                gender: gender,
                birthDate: birthDate,
                photoUrl: nil,
                createdAt: Date()
            )
            
            let petId = try await petService.addPet(pet)
            createdPetId = petId
            
            if let photoData {
                let url = try await imageStorageService.uploadPetImage(
                    petId: petId,
                    data: photoData
                )
                
                try await petService.updatePetPhoto(
                    petId: petId,
                    photoUrl: url
                )
                
            }
            
            shouldDismiss = true
            
        } catch {
            if let petId = createdPetId {
                try? await petService.deletePet(petId: petId)
            }
            
            errorMessage = "Failed to add pet. Please try again."
        }
        
        isLoading = false
    }
}

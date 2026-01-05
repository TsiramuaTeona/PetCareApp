//
//  AddPetViewModel.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 05.01.26.
//


import Foundation
import Combine

final class AddPetViewModel: ObservableObject {
    
    // MARK: - Properties
    
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
    
    private let householdId: String
    private let petService: PetServiceProtocol
    private let photoStorageService: PetPhotoStorageServiceProtocol
    
    // MARK: - Initializer
    
    init(
        householdId: String,
        petService: PetServiceProtocol,
        photoStorageService: PetPhotoStorageServiceProtocol
    ) {
        self.householdId = householdId
        self.petService = petService
        self.photoStorageService = photoStorageService
    }
    
    // MARK: - Methods
    
    func savePet() async {
        errorMessage = nil
        
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "Please enter a name."
            return
        }
        
        isLoading = true
        
        do {
            let newPet = Pet(
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
            
            let petId = try await petService.addPet(newPet)
            
            if let photoData {
                let url = try await photoStorageService.uploadPetPhoto(
                    petId: petId,
                    imageData: photoData
                )
                
                try await petService.updatePetPhoto(petId: petId, photoUrl: url)
            }
            
            shouldDismiss = true
            
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}

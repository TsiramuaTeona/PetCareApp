//
//  PetDetailsViewModel.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 03.01.26.
//


import Foundation
import Combine

@MainActor
final class PetDetailsViewModel: ObservableObject {
    // MARK: - Properties
    
    @Published private(set) var pet: Pet
    @Published private(set) var state: ScreenState = .loading
    @Published var alert: AppAlert?
    
    private let petService: PetServiceProtocol
    
    // MARK: - Initializer
    
    init(pet: Pet, petService: PetServiceProtocol) {
        self.pet = pet
        self.petService = petService
    }
    
    // MARK: - Methods
    
    func refresh() async {
        guard let petId = pet.id else { return }
        
        state = .loading
        do {
            pet = try await petService.getPet(petId: petId)
            state = .loaded
        } catch {
            state = .error(error.localizedDescription)
        }
    }
    
    func applyUpdatedPet(_ updatedPet: Pet) {
        self.pet = updatedPet
    }
    
    func deleteTapped(onSuccess: @escaping () -> Void) {
        alert = .deleteConfirmation(
            title: "Delete \(pet.name)?",
            message: "This action cannot be undone."
        ) { [weak self] in
            Task {
                await self?.deletePet(onSuccess: onSuccess)
            }
        }
    }
    
    private func deletePet(onSuccess: () -> Void) async {
        guard let petId = pet.id else { return }
        
        do {
            try await petService.deletePet(petId: petId)
            onSuccess()
        } catch {
            alert = .error(error.localizedDescription)
        }
    }
}

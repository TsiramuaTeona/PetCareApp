//
//  EditPetViewModelTests.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 23.01.26.
//

import Foundation
import Testing
@testable import PetCareApp

@Suite("EditPetViewModel")
@MainActor
struct EditPetViewModelTests {

    private func makePet(
        id: String? = "p1",
        name: String = "Luna",
        photoUrl: String? = "old.png"
    ) -> Pet {
        Pet(
            id: id,
            householdId: "h1",
            name: name,
            species: .cat,
            breed: "Siamese",
            gender: .female,
            birthDate: Date(timeIntervalSince1970: 1_700_000_000),
            photoUrl: photoUrl,
            color: "Gray",
            bio: "Hi",
            createdAt: Date()
        )
    }

    private func makeSUT(
        pet: Pet = Pet(
            id: "p1",
            householdId: "h1",
            name: "Luna",
            species: .cat,
            breed: "Siamese",
            gender: .female,
            birthDate: Date(timeIntervalSince1970: 1_700_000_000),
            photoUrl: "old.png",
            color: "Gray",
            bio: "Hi",
            createdAt: Date()
        ),
        petService: PetServiceMock = .init(),
        image: ImageStorageServiceMock = .init()
    ) -> (
        sut: EditPetViewModel,
        pet: PetServiceMock,
        image: ImageStorageServiceMock
    ) {
        let sut = EditPetViewModel(
            pet: pet,
            petService: petService,
            imageStorageService: image
        )
        return (sut, petService, image)
    }

    @Test("init copies pet fields into editable state")
    func init_copiesFields() async {
        let pet = makePet(name: "Luna", photoUrl: "old.png")
        let (sut, _, _) = makeSUT(pet: pet)

        #expect(sut.name == "Luna")
        #expect(sut.species == .cat)
        #expect(sut.breed == "Siamese")
        #expect(sut.gender == .female)
        #expect(sut.color == "Gray")
        #expect(sut.bio == "Hi")
        #expect(sut.currentPhotoUrl == "old.png")
    }

    @Test("save: originalPet.id is nil -> returns nil, no calls, state unchanged")
    func save_petIdNil_returnsNil() async {
        let pet = makePet(id: nil)
        let (sut, petService, image) = makeSUT(pet: pet)

        let result = await sut.save()

        #expect(result == nil)
        #expect(petService.updateCalls.isEmpty)
        #expect(petService.updatePhotoCalls.isEmpty)
        #expect(image.uploadPetCalls.isEmpty)
        #expect(sut.state == .loaded)
    }

    @Test("save: success without photo -> updates pet, trims/cleans fields, returns updated pet")
    func save_success_noPhoto() async {
        let pet = makePet(id: "p1", name: "Luna", photoUrl: "old.png")
        let petService = PetServiceMock()
        let image = ImageStorageServiceMock()

        let (sut, petMock, imageMock) = makeSUT(pet: pet, petService: petService, image: image)

        sut.name = "  New Name  "
        sut.breed = "   "
        sut.color = ""
        sut.bio = "Updated bio"
        sut.species = .dog
        sut.gender = .male

        let result = await sut.save()

        #expect(sut.state == .loaded)
        #expect(result != nil)

        #expect(petMock.updateCalls.count == 1)
        let updatedSent = petMock.updateCalls[0]
        #expect(updatedSent.id == "p1")
        #expect(updatedSent.name == "New Name")
        #expect(updatedSent.species == .dog)
        #expect(updatedSent.gender == .male)
        #expect(updatedSent.breed == nil)
        #expect(updatedSent.color == nil)
        #expect(updatedSent.bio == "Updated bio")

        #expect(imageMock.uploadPetCalls.isEmpty)
        #expect(petMock.updatePhotoCalls.isEmpty)

        #expect(result?.name == "New Name")
        #expect(result?.photoUrl == "old.png")
    }

    @Test("save: success with photo -> uploads and updates photo url")
    func save_success_withPhoto_uploadsAndUpdatesPhoto() async {
        let pet = makePet(id: "p1", name: "Luna", photoUrl: "old.png")
        let petService = PetServiceMock()
        let image = ImageStorageServiceMock()
        image.uploadPetImageResult = "https://cdn/new.png"

        let (sut, petMock, imageMock) = makeSUT(pet: pet, petService: petService, image: image)

        sut.name = "Luna"
        sut.photoData = Data([1, 2, 3, 4])

        let result = await sut.save()

        #expect(sut.state == .loaded)
        #expect(result != nil)

        #expect(petMock.updateCalls.count == 1)

        #expect(imageMock.uploadPetCalls.count == 1)
        #expect(imageMock.uploadPetCalls[0].petId == "p1")
        #expect(imageMock.uploadPetCalls[0].size == 4)

        #expect(petMock.updatePhotoCalls.count == 1)
        #expect(petMock.updatePhotoCalls[0].petId == "p1")
        #expect(petMock.updatePhotoCalls[0].url == "https://cdn/new.png")

        #expect(result?.photoUrl == "https://cdn/new.png")
    }

    @Test("save: updatePet fails -> sets error state and returns nil (no upload/updatePhoto)")
    func save_updatePetFails_setsError() async {
        let pet = makePet(id: "p1")
        let petService = PetServiceMock()
        petService.updateError = TestError.message("update fail")

        let (sut, petMock, imageMock) = makeSUT(pet: pet, petService: petService)

        sut.name = "New"

        let result = await sut.save()

        #expect(result == nil)

        switch sut.state {
        case .error(let msg):
            #expect(!msg.isEmpty)
        default:
            #expect(Bool(false), "Expected .error state")
        }

        #expect(petMock.updateCalls.count == 1)
        #expect(imageMock.uploadPetCalls.isEmpty)
        #expect(petMock.updatePhotoCalls.isEmpty)
    }

    @Test("save: uploadPetImage fails -> sets error, returns nil (updatePet was called)")
    func save_uploadFails_setsError() async {
        let pet = makePet(id: "p1")
        let petService = PetServiceMock()
        let image = ImageStorageServiceMock()
        image.uploadPetImageError = TestError.message("upload fail")

        let (sut, petMock, imageMock) = makeSUT(pet: pet, petService: petService, image: image)

        sut.name = "New"
        sut.photoData = Data([9])

        let result = await sut.save()

        #expect(result == nil)

        switch sut.state {
        case .error(let msg):
            #expect(!msg.isEmpty)
        default:
            #expect(Bool(false), "Expected .error state")
        }

        #expect(petMock.updateCalls.count == 1)
        #expect(imageMock.uploadPetCalls.count == 1)
        #expect(petMock.updatePhotoCalls.isEmpty)
    }

    @Test("save: updatePetPhoto fails -> sets error, returns nil (updatePet + upload were called)")
    func save_updatePhotoFails_setsError() async {
        let pet = makePet(id: "p1")
        let petService = PetServiceMock()
        petService.updatePhotoError = TestError.message("photo fail")

        let image = ImageStorageServiceMock()
        image.uploadPetImageResult = "https://cdn/x.png"

        let (sut, petMock, imageMock) = makeSUT(pet: pet, petService: petService, image: image)

        sut.name = "New"
        sut.photoData = Data([1, 2])

        let result = await sut.save()

        #expect(result == nil)

        switch sut.state {
        case .error(let msg):
            #expect(!msg.isEmpty)
        default:
            #expect(Bool(false), "Expected .error state")
        }

        #expect(petMock.updateCalls.count == 1)
        #expect(imageMock.uploadPetCalls.count == 1)
        #expect(petMock.updatePhotoCalls.count == 1)
    }
}

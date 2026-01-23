//
//  AddPetViewModelTests.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 23.01.26.
//

import Foundation
import Testing
@testable import PetCareApp

@Suite("AddPetViewModel")
@MainActor
struct AddPetViewModelTests {

    private func makeSUT(
        householdId: String = "h1",
        petService: PetServiceMock = .init(),
        image: ImageStorageServiceMock = .init()
    ) -> (
        sut: AddPetViewModel,
        pet: PetServiceMock,
        image: ImageStorageServiceMock
    ) {
        let sut = AddPetViewModel(
            householdId: householdId,
            petService: petService,
            imageStorageService: image
        )
        return (sut, petService, image)
    }

    @Test("savePet: empty name -> sets validation error, no service calls")
    func savePet_emptyName_setsError_noCalls() async {
        let (sut, petService, image) = makeSUT()
        sut.name = "   "

        await sut.savePet()

        #expect(sut.errorMessage == "Please enter a name.")
        #expect(sut.isLoading == false)
        #expect(sut.shouldDismiss == false)

        #expect(petService.addCalls.isEmpty)
        #expect(image.uploadPetCalls.isEmpty)
        #expect(petService.updatePhotoCalls.isEmpty)
        #expect(petService.deleteCalls.isEmpty)
    }

    @Test("savePet: success without photo -> adds pet, dismisses, does not upload/update photo")
    func savePet_success_noPhoto() async {
        let (sut, petService, image) = makeSUT()

        sut.name = "Luna"
        sut.species = .cat
        sut.breed = ""
        sut.gender = .female

        await sut.savePet()

        #expect(sut.errorMessage == nil)
        #expect(sut.isLoading == false)
        #expect(sut.shouldDismiss == true)

        #expect(petService.addCalls.count == 1)
        let created = petService.addCalls[0]
        #expect(created.id == nil)
        #expect(created.householdId == "h1")
        #expect(created.name == "Luna")
        #expect(created.species == .cat)
        #expect(created.gender == .female)
        #expect(created.breed == nil)

        #expect(image.uploadPetCalls.isEmpty)
        #expect(petService.updatePhotoCalls.isEmpty)
        #expect(petService.deleteCalls.isEmpty)
    }

    @Test("savePet: success with photo -> uploads image and updates photo url")
    func savePet_success_withPhoto_uploadsAndUpdates() async {
        let (sut, petService, image) = makeSUT()

        sut.name = "Max"
        sut.photoData = Data([0, 1, 2, 3])
        image.uploadPetImageResult = "https://cdn/max.png"

        await sut.savePet()

        #expect(sut.errorMessage == nil)
        #expect(sut.shouldDismiss == true)

        #expect(petService.addCalls.count == 1)

        #expect(image.uploadPetCalls.count == 1)
        let uploadedPetId = image.uploadPetCalls[0].petId
        #expect(image.uploadPetCalls[0].size == 4)

        #expect(petService.updatePhotoCalls.count == 1)
        #expect(petService.updatePhotoCalls[0].petId == uploadedPetId)
        #expect(petService.updatePhotoCalls[0].url == "https://cdn/max.png")

        #expect(petService.deleteCalls.isEmpty)
    }

    @Test("savePet: addPet fails -> sets generic error, does not delete (no created id)")
    func savePet_addPetFails_setsGenericError() async {
        let petService = PetServiceMock()
        petService.addError = TestError.message("add fail")

        let (sut, petMock, image) = makeSUT(petService: petService)

        sut.name = "Luna"
        sut.photoData = Data([1, 2, 3])

        await sut.savePet()

        #expect(sut.shouldDismiss == false)
        #expect(sut.isLoading == false)
        #expect(sut.errorMessage == "Failed to add pet. Please try again.")

        #expect(petMock.addCalls.count == 1)
        #expect(image.uploadPetCalls.isEmpty)
        #expect(petMock.updatePhotoCalls.isEmpty)
        #expect(petMock.deleteCalls.isEmpty)
    }

    @Test("savePet: uploadPetImage fails after pet created -> deletes created pet, sets generic error")
    func savePet_uploadFails_rollsBack() async {
        let petService = PetServiceMock()
        let image = ImageStorageServiceMock()
        image.uploadPetImageError = TestError.message("upload fail")

        let (sut, petMock, _) = makeSUT(petService: petService, image: image)

        sut.name = "Luna"
        sut.photoData = Data([9, 9, 9])

        await sut.savePet()

        #expect(sut.shouldDismiss == false)
        #expect(sut.errorMessage == "Failed to add pet. Please try again.")

        #expect(petMock.addCalls.count == 1)
        #expect(image.uploadPetCalls.count == 1)

        #expect(petMock.deleteCalls.count == 1)
        let deletedId = petMock.deleteCalls[0]
        #expect(!deletedId.isEmpty)
    }

    @Test("savePet: updatePetPhoto fails after upload -> deletes created pet, sets generic error")
    func savePet_updatePhotoFails_rollsBack() async {
        let petService = PetServiceMock()
        petService.updatePhotoError = TestError.message("update fail")

        let image = ImageStorageServiceMock()
        image.uploadPetImageResult = "https://cdn/a.png"

        let (sut, petMock, imageMock) = makeSUT(petService: petService, image: image)

        sut.name = "Luna"
        sut.photoData = Data([7, 7])

        await sut.savePet()

        #expect(sut.shouldDismiss == false)
        #expect(sut.errorMessage == "Failed to add pet. Please try again.")

        #expect(petMock.addCalls.count == 1)
        #expect(imageMock.uploadPetCalls.count == 1)
        #expect(petMock.updatePhotoCalls.count == 1)

        #expect(petMock.deleteCalls.count == 1)
        let deletedId = petMock.deleteCalls[0]
        #expect(!deletedId.isEmpty)
    }
}

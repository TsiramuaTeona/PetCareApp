//
//  PetDetailsViewModelTests.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 23.01.26.
//

import Foundation
import Testing
@testable import PetCareApp

@Suite("PetDetailsViewModel")
@MainActor
struct PetDetailsViewModelTests {

    private func makePet(id: String = "p1", name: String = "Luna") -> Pet {
        Pet(
            id: id,
            householdId: "h1",
            name: name,
            species: .cat,
            breed: nil,
            gender: .female,
            birthDate: Date(),
            photoUrl: nil,
            createdAt: Date()
        )
    }

    private func makeSUT(
        pet: Pet = Pet(
            id: "p1",
            householdId: "h1",
            name: "Luna",
            species: .cat,
            breed: nil,
            gender: .female,
            birthDate: Date(),
            photoUrl: nil,
            createdAt: Date()
        ),
        petService: PetServiceMock = .init(),
        healthService: HealthServiceMock = .init(),
        notification: NotificationServiceMock = .init()
    ) -> (
        sut: PetDetailsViewModel,
        petService: PetServiceMock,
        healthService: HealthServiceMock,
        notification: NotificationServiceMock
    ) {

        let sut = PetDetailsViewModel(
            pet: pet,
            petService: petService,
            healthService: healthService,
            notificationService: notification
        )

        return (sut, petService, healthService, notification)
    }

    @Test("refresh when pet.id is nil -> returns early, no calls, state stays loading")
    func refresh_petIdNil_returnsEarly() async {
        var pet = makePet()
        pet.id = nil

        let petService = PetServiceMock()
        let healthService = HealthServiceMock()

        let (sut, _, _, _) = makeSUT(pet: pet, petService: petService, healthService: healthService)

        await sut.refresh()

        #expect(petService.getPetCalls.isEmpty)
        #expect(healthService.fetchCalls.isEmpty)
        #expect(sut.state == .loading)
    }

    @Test("refresh success -> updates pet, splits logs into upcomingAlerts/historyLogs, sets loaded")
    func refresh_success_updatesStateAndLogs() async {
        let pet = makePet(id: "p1", name: "Luna")

        let petService = PetServiceMock()
        petService.petsById["p1"] = makePet(id: "p1", name: "Luna Updated")

        let now = Date()
        let dueSoon = now.addingTimeInterval(60)
        let dueLater = now.addingTimeInterval(120)

        let upcoming1 = HealthLog(
            id: "u1",
            petId: "p1",
            category: .vet,
            title: "Vet Visit",
            note: nil,
            date: now,
            isResolved: false,
            completedDate: nil,
            nextDueDate: dueLater,
            recurrence: nil,
            value: nil,
            dosage: nil,
            timesPerDay: nil,
            reminderTimes: nil,
            durationDays: nil,
            medicationCourseStart: nil
        )

        let upcoming2 = HealthLog(
            id: "u2",
            petId: "p1",
            category: .vaccine,
            title: "Rabies",
            note: nil,
            date: now,
            isResolved: false,
            completedDate: nil,
            nextDueDate: dueSoon,
            recurrence: nil,
            value: nil,
            dosage: nil,
            timesPerDay: nil,
            reminderTimes: nil,
            durationDays: nil,
            medicationCourseStart: nil
        )

        let historyResolved = HealthLog(
            id: "h1",
            petId: "p1",
            category: .weight,
            title: "4.2 kg",
            note: nil,
            date: now.addingTimeInterval(-86400),
            isResolved: true,
            completedDate: now.addingTimeInterval(-86400),
            nextDueDate: nil,
            recurrence: nil,
            value: 4.2,
            dosage: nil,
            timesPerDay: nil,
            reminderTimes: nil,
            durationDays: nil,
            medicationCourseStart: nil
        )

        let historyNoDue = HealthLog(
            id: "h2",
            petId: "p1",
            category: .vet,
            title: "Past event",
            note: nil,
            date: now.addingTimeInterval(-3600),
            isResolved: false,
            completedDate: nil,
            nextDueDate: nil,
            recurrence: nil,
            value: nil,
            dosage: nil,
            timesPerDay: nil,
            reminderTimes: nil,
            durationDays: nil,
            medicationCourseStart: nil
        )

        let healthService = HealthServiceMock()
        healthService.logsByPetId["p1"] = [upcoming1, historyResolved, upcoming2, historyNoDue]

        let (sut, _, _, _) = makeSUT(pet: pet, petService: petService, healthService: healthService)

        await sut.refresh()

        #expect(sut.state == .loaded)
        #expect(sut.pet.name == "Luna Updated")

        #expect(sut.upcomingAlerts.map(\.id) == ["u2", "u1"])

        #expect(sut.historyLogs.map(\.id) == ["h2", "h1"])

        #expect(sut.weightLogs.map(\.id) == ["h1"])
        #expect(sut.medicationLogs.isEmpty)
        #expect(sut.weightText.contains("4.2"))
    }

    @Test("refresh failure -> sets error state")
    func refresh_failure_setsError() async {
        let pet = makePet(id: "p1", name: "Luna")

        let petService = PetServiceMock()
        petService.getPetError = TestError.message("pet fail")

        let healthService = HealthServiceMock()

        let (sut, _, _, _) = makeSUT(pet: pet, petService: petService, healthService: healthService)

        await sut.refresh()

        switch sut.state {
        case .error(let msg):
            #expect(msg.contains("pet fail"))
        default:
            #expect(Bool(false), "Expected .error")
        }
    }

    @Test("applyUpdatedPet replaces current pet")
    func applyUpdatedPet_updatesPet() async {
        let pet = makePet(id: "p1", name: "Luna")
        let (sut, _, _, _) = makeSUT(pet: pet)

        let updated = makePet(id: "p1", name: "New Name")
        sut.applyUpdatedPet(updated)

        #expect(sut.pet.name == "New Name")
    }

    @Test("deleteLog success -> cancels notification, deletes log, refreshes")
    func deleteLog_success() async {
        let pet = makePet(id: "p1", name: "Luna")

        let petService = PetServiceMock()
        petService.petsById["p1"] = pet

        let log = HealthLog(
            id: "l1",
            petId: "p1",
            category: .vet,
            title: "Visit",
            note: nil,
            date: Date(),
            isResolved: false,
            completedDate: nil,
            nextDueDate: Date().addingTimeInterval(60),
            recurrence: nil,
            value: nil,
            dosage: nil,
            timesPerDay: nil,
            reminderTimes: nil,
            durationDays: nil,
            medicationCourseStart: nil
        )

        let health = HealthServiceMock()
        health.logsByPetId["p1"] = [log]

        let notification = NotificationServiceMock()

        let (sut, _, _, _) = makeSUT(pet: pet, petService: petService, healthService: health, notification: notification)

        await sut.deleteLog(log)

        #expect(notification.cancelCalls == ["l1"])
        #expect(health.deleteCalls.count == 1)
        #expect(health.deleteCalls[0].petId == "p1")
        #expect(health.deleteCalls[0].logId == "l1")
        #expect(sut.state == .loaded)
    }

    @Test("deleteLog failure -> sets alert error")
    func deleteLog_failure_setsAlert() async {
        let pet = makePet(id: "p1", name: "Luna")

        let log = HealthLog(
            id: "l1",
            petId: "p1",
            category: .vet,
            title: "Visit",
            note: nil,
            date: Date(),
            isResolved: false,
            completedDate: nil,
            nextDueDate: Date().addingTimeInterval(60),
            recurrence: nil,
            value: nil,
            dosage: nil,
            timesPerDay: nil,
            reminderTimes: nil,
            durationDays: nil,
            medicationCourseStart: nil
        )

        let petService = PetServiceMock()
        petService.petsById["p1"] = pet

        let health = HealthServiceMock()
        health.deleteLogError = TestError.message("delete fail")

        let (sut, _, _, _) = makeSUT(pet: pet, petService: petService, healthService: health)

        await sut.deleteLog(log)

        #expect(sut.alert != nil)
    }

    @Test("resolveLog updates log, cancels notification, refreshes (without asserting recurrence)")
    func resolveLog_baseBehavior() async {
        let pet = makePet(id: "p1", name: "Luna")

        let petService = PetServiceMock()
        petService.petsById["p1"] = pet

        let now = Date()

        let log = HealthLog(
            id: "l1",
            petId: "p1",
            category: .vaccine,
            title: "Rabies",
            note: nil,
            date: now,
            isResolved: false,
            completedDate: nil,
            nextDueDate: now.addingTimeInterval(60),
            recurrence: .yearly,
            value: nil,
            dosage: nil,
            timesPerDay: nil,
            reminderTimes: nil,
            durationDays: nil,
            medicationCourseStart: nil
        )

        let health = HealthServiceMock()
        health.logsByPetId["p1"] = [log]

        let notification = NotificationServiceMock()

        let (sut, _, _, _) = makeSUT(pet: pet, petService: petService, healthService: health, notification: notification)

        await sut.resolveLog(log)

        #expect(health.updateCalls.count == 1)
        let updated = health.updateCalls[0]
        #expect(updated.isResolved == true)
        #expect(updated.completedDate != nil)
        #expect(updated.nextDueDate == nil)

        #expect(notification.cancelCalls == ["l1"])
        #expect(sut.state == .loaded)
    }

    @Test("resolveLog update fails -> sets alert error")
    func resolveLog_failure_setsAlert() async {
        let pet = makePet(id: "p1", name: "Luna")

        let log = HealthLog(
            id: "l1",
            petId: "p1",
            category: .vaccine,
            title: "Rabies",
            note: nil,
            date: Date(),
            isResolved: false,
            completedDate: nil,
            nextDueDate: Date().addingTimeInterval(60),
            recurrence: nil,
            value: nil,
            dosage: nil,
            timesPerDay: nil,
            reminderTimes: nil,
            durationDays: nil,
            medicationCourseStart: nil
        )

        let petService = PetServiceMock()
        petService.petsById["p1"] = pet

        let health = HealthServiceMock()
        health.updateLogError = TestError.message("update fail")

        let (sut, _, _, _) = makeSUT(pet: pet, petService: petService, healthService: health)

        await sut.resolveLog(log)

        #expect(sut.alert != nil)
    }

    @Test("deleteTapped sets deleteConfirmation alert")
    func deleteTapped_setsConfirmationAlert() async {
        let pet = makePet(id: "p1", name: "Luna")
        let (sut, _, _, _) = makeSUT(pet: pet)

        sut.deleteTapped(onSuccess: {})

        #expect(sut.alert != nil)
    }

    @Test("deleteTapped confirm -> runs deletePet flow and calls onSuccess")
    func deleteTapped_confirm_executesDeleteFlow() async {
        let pet = makePet(id: "p1", name: "Luna")
        
        let petService = PetServiceMock()
        petService.petsById["p1"] = pet
        
        let health = HealthServiceMock()
        let l1 = HealthLog(
            id: "l1", petId: "p1", category: .vet, title: "A", note: nil,
            date: Date(), isResolved: false, completedDate: nil,
            nextDueDate: Date().addingTimeInterval(10), recurrence: nil,
            value: nil, dosage: nil, timesPerDay: nil, reminderTimes: nil,
            durationDays: nil, medicationCourseStart: nil
        )
        let l2 = HealthLog(
            id: "l2", petId: "p1", category: .vaccine, title: "B", note: nil,
            date: Date(), isResolved: true, completedDate: Date(),
            nextDueDate: nil, recurrence: nil,
            value: nil, dosage: nil, timesPerDay: nil, reminderTimes: nil,
            durationDays: nil, medicationCourseStart: nil
        )
        health.logsByPetId["p1"] = [l1, l2]
        
        let notification = NotificationServiceMock()
        
        let (sut, _, _, _) = makeSUT(
            pet: pet,
            petService: petService,
            healthService: health,
            notification: notification
        )
        
        var didCallSuccess = false
        sut.deleteTapped(onSuccess: { didCallSuccess = true })
        
        #expect(sut.alert?.title == "Delete Luna?")
        #expect(sut.alert?.primary.title == "Delete")
        #expect(sut.alert?.primary.style == .destructive)
        
        sut.alert?.primary.handler?()
        
        await Task.yield()
        
        #expect(notification.cancelCalls.contains("l1"))
        #expect(notification.cancelCalls.contains("l2"))
        #expect(health.deleteAllCalls == ["p1"])
        #expect(petService.deleteCalls == ["p1"])
        #expect(didCallSuccess == true)
    }
}

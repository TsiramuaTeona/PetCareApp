//
//  AddHealthLogViewModelTests.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 23.01.26.
//

import Foundation
import Testing
@testable import PetCareApp

@Suite("AddHealthLogViewModel")
@MainActor
struct AddHealthLogViewModelTests {

    private func makeSUT(
        petId: String = "p1",
        category: LogCategory = .vaccine,
        health: HealthServiceMock = .init(),
        reminder: ReminderSyncServiceMock = .init()
    ) -> (sut: AddHealthLogViewModel, health: HealthServiceMock, reminder: ReminderSyncServiceMock) {
        let sut = AddHealthLogViewModel(
            petId: petId,
            category: category,
            healthService: health,
            reminderService: reminder
        )
        return (sut, health, reminder)
    }

    @Test("Non-weight with empty title -> validation error, no service calls")
    func nonWeight_emptyTitle_showsError_noCalls() async {
        let (sut, health, reminder) = makeSUT(category: .vaccine)

        sut.title = "   "
        sut.actionDate = Date().addingTimeInterval(60)
        sut.addReminder = true

        await sut.save()

        #expect(sut.errorMessage == "Please enter a title.")
        #expect(health.addCalls.isEmpty)
        #expect(reminder.scheduleCalls.isEmpty)
    }

    @Test("Medication with empty dosage -> validation error, no calls")
    func medication_emptyDosage_showsError_noCalls() async {
        let (sut, health, reminder) = makeSUT(category: .medication)

        sut.title = "Antibiotic"
        sut.dosage = "   "
        sut.timesPerDay = 2
        sut.actionDate = Date().addingTimeInterval(60)

        await sut.save()

        #expect(sut.errorMessage == "Please enter dosage.")
        #expect(health.addCalls.isEmpty)
        #expect(reminder.scheduleCalls.isEmpty)
    }

    @Test("Weight with invalid number -> validation error, no calls")
    func weight_invalidValue_showsError_noCalls() async {
        let (sut, health, reminder) = makeSUT(category: .weight)

        sut.valueString = "abc"
        sut.actionDate = Date().addingTimeInterval(60)

        await sut.save()

        #expect(sut.errorMessage == "Please enter a valid weight value.")
        #expect(health.addCalls.isEmpty)
        #expect(reminder.scheduleCalls.isEmpty)
    }

    @Test("History non-medication, addReminder=false -> creates ONLY history log, no future, no reminder schedule")
    func historyNonMedication_noReminder_createsHistoryOnly() async {
        let (sut, health, reminder) = makeSUT(category: .vet)

        sut.title = "Checkup"
        sut.note = " yearly "
        sut.actionDate = Date().addingTimeInterval(-86400 * 10)
        sut.addReminder = false

        await sut.save()

        #expect(sut.errorMessage == nil)
        #expect(health.addCalls.count == 1)
        #expect(reminder.scheduleCalls.isEmpty)

        let created = health.addCalls[0]
        #expect(created.isResolved == true)
        #expect(created.completedDate != nil)
        #expect(created.nextDueDate == nil)
        #expect(created.title == "Checkup")
        #expect(created.note == "yearly")
    }

    @Test("History non-medication, addReminder=true -> creates history log + future log and schedules reminder")
    func historyNonMedication_withReminder_createsHistoryAndFuture_andSchedules() async {
        let (sut, health, reminder) = makeSUT(category: .vaccine)

        sut.title = "Rabies"
        sut.actionDate = Date().addingTimeInterval(-86400 * 2)
        sut.addReminder = true
        sut.nextDueDate = Date().addingTimeInterval(86400 * 30)
        sut.recurrence = .yearly

        await sut.save()

        #expect(sut.errorMessage == nil)
        #expect(health.addCalls.count == 2)
        #expect(reminder.scheduleCalls.count == 1)

        let history = health.addCalls[0]
        #expect(history.isResolved == true)
        #expect(history.nextDueDate == nil)

        let future = health.addCalls[1]
        #expect(future.isResolved == false)
        #expect(future.nextDueDate == sut.nextDueDate)
        #expect(future.date == sut.nextDueDate)
        #expect(future.recurrence == .yearly)
    }

    @Test("Future non-medication (actionDate in future) -> creates ONLY future log and schedules reminder")
    func futureNonMedication_createsFuture_only_andSchedules() async {
        let (sut, health, reminder) = makeSUT(category: .grooming)

        let futureDate = Date().addingTimeInterval(86400 * 3)
        sut.title = "Groom"
        sut.actionDate = futureDate
        sut.addReminder = false
        sut.recurrence = .monthly

        await sut.save()

        #expect(sut.errorMessage == nil)
        #expect(health.addCalls.count == 1)
        #expect(reminder.scheduleCalls.count == 1)

        let future = health.addCalls[0]
        #expect(future.isResolved == false)
        #expect(future.date == futureDate)
        #expect(future.nextDueDate == futureDate)
        #expect(future.recurrence == .monthly)
    }

    @Test("Medication history creates multiple resolved logs (>=1), no reminder schedule if no future created")
    func medicationHistory_createsManyHistoryLogs() async {
        let (sut, health, reminder) = makeSUT(category: .medication)

        sut.title = "Antibiotic"
        sut.dosage = "1 pill"
        sut.timesPerDay = 2
        sut.isChronic = false
        sut.durationDays = 1

        sut.actionDate = Date().addingTimeInterval(-86400 * 5)
        
        await sut.save()

        #expect(sut.errorMessage == nil)
        #expect(health.addCalls.count >= 1)
        #expect(reminder.scheduleCalls.isEmpty)

        for log in health.addCalls {
            #expect(log.category == .medication)
            #expect(log.isResolved == true)
            #expect(log.completedDate != nil)
            #expect(log.nextDueDate == nil)
            #expect(log.dosage == "1 pill")
            #expect(log.timesPerDay == 2)
        }
    }

    @Test("Medication chronic + future actionDate -> creates future log with daily recurrence and schedules reminder")
    func medicationChronic_future_createsFutureDaily_andSchedules() async {
        let (sut, health, reminder) = makeSUT(category: .medication)

        let future = Date().addingTimeInterval(86400 * 2)

        sut.title = "Allergy meds"
        sut.dosage = "5mg"
        sut.timesPerDay = 2
        sut.isChronic = true
        sut.actionDate = future

        await sut.save()

        #expect(sut.errorMessage == nil)
        #expect(health.addCalls.count == 1)
        #expect(reminder.scheduleCalls.count == 1)

        let log = health.addCalls[0]
        #expect(log.isResolved == false)
        #expect(log.recurrence == .daily)
        #expect(log.reminderTimes?.count == 2)
        #expect(log.nextDueDate == future)
        #expect(log.medicationCourseStart == nil)
        #expect(log.durationDays == nil)
    }

    @Test("Medication non-chronic with durationDays<=0 -> treated as endless -> creates future log")
    func medicationNonChronic_invalidDuration_createsFuture() async {
        let (sut, health, reminder) = makeSUT(category: .medication)

        let future = Date().addingTimeInterval(3600)

        sut.title = "Course"
        sut.dosage = "1 pill"
        sut.timesPerDay = 1
        sut.isChronic = false
        sut.durationDays = 0
        sut.actionDate = future

        await sut.save()

        #expect(sut.errorMessage == nil)
        #expect(health.addCalls.count == 1)
        #expect(reminder.scheduleCalls.count == 1)

        let log = health.addCalls[0]
        #expect(log.isResolved == false)
        #expect(log.recurrence == .daily)
        #expect(log.durationDays == 0)
    }

    @Test("save toggles isLoading true during work and ends false")
    func save_setsLoading_andEndsFalse() async {
        let (sut, _, _) = makeSUT(category: .vaccine)

        sut.title = "Rabies"
        sut.actionDate = Date().addingTimeInterval(3600)

        #expect(sut.isLoading == false)
        await sut.save()
        #expect(sut.isLoading == false)
    }

    @Test("Changing category resets fields to defaults")
    func changingCategory_resetsFields() {
        let (sut, _, _) = makeSUT(category: .vaccine)

        sut.title = "X"
        sut.note = "Y"
        sut.valueString = "10"
        sut.addReminder = true
        sut.recurrence = .monthly
        sut.nextDueDate = Date().addingTimeInterval(9999)
        sut.dosage = "Z"
        sut.timesPerDay = 3
        sut.isChronic = true
        sut.durationDays = 10

        sut.category = .medication

        #expect(sut.title == "")
        #expect(sut.note == "")
        #expect(sut.valueString == "")
        #expect(sut.addReminder == false)
        #expect(sut.recurrence == .none)
        #expect(sut.dosage == "")
        #expect(sut.timesPerDay == 1)
        #expect(sut.isChronic == false)
        #expect(sut.durationDays == 7)
        #expect(sut.errorMessage == nil)
    }
}

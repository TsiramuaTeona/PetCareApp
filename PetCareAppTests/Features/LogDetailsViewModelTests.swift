//
//  LogDetailsViewModelTests.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 23.01.26.
//

import Foundation
import Testing
@testable import PetCareApp

@Suite("LogDetailsViewModel")
@MainActor
struct LogDetailsViewModelTests {

    private func makeSUT(
        petId: String = "p1",
        petName: String = "Luna",
        sourceLog: HealthLog,
        health: HealthServiceMock = .init(),
        calendar: CalendarServiceMock = .init(),
        reminder: ReminderSyncServiceMock = .init(),
        notification: NotificationServiceMock = .init()
    ) -> (sut: LogDetailsViewModel,
          health: HealthServiceMock,
          calendar: CalendarServiceMock,
          reminder: ReminderSyncServiceMock,
          notification: NotificationServiceMock) {

        let sut = LogDetailsViewModel(
            petId: petId,
            petName: petName,
            sourceLog: sourceLog,
            healthService: health,
            calendarService: calendar,
            reminderService: reminder,
            notificationService: notification
        )
        return (sut, health, calendar, reminder, notification)
    }

    @Test("refresh non-weight groups by category+normalized title, populates upcoming/history/chart, updates sourceLog")
    func refresh_nonWeight_groupsCorrectly() async {
        let now = Date()

        let source = HealthLog(
            id: "s1",
            petId: "p1",
            category: .vaccine,
            title: "Rabies",
            note: nil,
            date: now.addingTimeInterval(-1000),
            isResolved: false,
            completedDate: nil,
            nextDueDate: now.addingTimeInterval(3600),
            recurrence: .yearly,
            value: nil,
            dosage: nil,
            timesPerDay: nil,
            reminderTimes: nil,
            durationDays: nil,
            medicationCourseStart: nil
        )

        let matchUpcoming = HealthLog(
            id: "u1",
            petId: "p1",
            category: .vaccine,
            title: "  rabies  ",
            note: nil,
            date: now,
            isResolved: false,
            completedDate: nil,
            nextDueDate: now.addingTimeInterval(1800),
            recurrence: .yearly,
            value: nil,
            dosage: nil,
            timesPerDay: nil,
            reminderTimes: nil,
            durationDays: nil,
            medicationCourseStart: nil
        )

        let matchHistoryResolved = HealthLog(
            id: "h1",
            petId: "p1",
            category: .vaccine,
            title: "RABIES",
            note: nil,
            date: now.addingTimeInterval(-86400),
            isResolved: true,
            completedDate: now.addingTimeInterval(-86400),
            nextDueDate: nil,
            recurrence: .yearly,
            value: nil,
            dosage: nil,
            timesPerDay: nil,
            reminderTimes: nil,
            durationDays: nil,
            medicationCourseStart: nil
        )

        let nonMatchDifferentTitle = HealthLog(
            id: "x1",
            petId: "p1",
            category: .vaccine,
            title: "Parvo",
            note: nil,
            date: now,
            isResolved: false,
            completedDate: nil,
            nextDueDate: now.addingTimeInterval(100),
            recurrence: .yearly,
            value: nil,
            dosage: nil,
            timesPerDay: nil,
            reminderTimes: nil,
            durationDays: nil,
            medicationCourseStart: nil
        )

        let health = HealthServiceMock()
        health.logsByPetId["p1"] = [
            nonMatchDifferentTitle,
            matchHistoryResolved,
            matchUpcoming,
            source
        ]

        let (sut, _, _, _, _) = makeSUT(sourceLog: source, health: health)

        await sut.refresh()

        #expect(sut.state == .loaded)
        #expect(sut.upcomingLogs.map(\.id) == ["u1", "s1"])
        #expect(sut.historyLogs.map(\.id) == ["h1"])
        #expect(sut.chartData.map(\.id) == ["h1"])
        #expect(sut.sourceLog.id == "s1")
    }

    @Test("refresh weight groups ALL weight logs regardless of title")
    func refresh_weight_groupsAllWeight() async {
        let now = Date()

        let source = HealthLog(
            id: "w0",
            petId: "p1",
            category: .weight,
            title: "4.2 kg",
            note: nil,
            date: now.addingTimeInterval(-1000),
            isResolved: true,
            completedDate: now.addingTimeInterval(-1000),
            nextDueDate: nil,
            recurrence: nil,
            value: 4.2,
            dosage: nil,
            timesPerDay: nil,
            reminderTimes: nil,
            durationDays: nil,
            medicationCourseStart: nil
        )

        let anotherWeight = HealthLog(
            id: "w1",
            petId: "p1",
            category: .weight,
            title: "4.3 kg",
            note: nil,
            date: now.addingTimeInterval(-2000),
            isResolved: true,
            completedDate: now.addingTimeInterval(-2000),
            nextDueDate: nil,
            recurrence: nil,
            value: 4.3,
            dosage: nil,
            timesPerDay: nil,
            reminderTimes: nil,
            durationDays: nil,
            medicationCourseStart: nil
        )

        let nonWeight = HealthLog(
            id: "x",
            petId: "p1",
            category: .vet,
            title: "Checkup",
            note: nil,
            date: now,
            isResolved: false,
            completedDate: nil,
            nextDueDate: now.addingTimeInterval(100),
            recurrence: nil,
            value: nil,
            dosage: nil,
            timesPerDay: nil,
            reminderTimes: nil,
            durationDays: nil,
            medicationCourseStart: nil
        )

        let health = HealthServiceMock()
        health.logsByPetId["p1"] = [nonWeight, anotherWeight, source]

        let (sut, _, _, _, _) = makeSUT(sourceLog: source, health: health)

        await sut.refresh()

        #expect(sut.state == .loaded)
        #expect(sut.historyLogs.map(\.id) == ["w0", "w1"])
        #expect(sut.chartData.map(\.id) == ["w1", "w0"])
        #expect(sut.upcomingLogs.isEmpty)
    }

    // MARK: - saveLogEdits

    @Test("saveLogEdits non-med not resolved -> updates nextDueDate, clears reminderTimes, cancels old notification, schedules reminder, refreshes")
    func saveLogEdits_nonMedication_notResolved_schedules() async {
        let original = HealthLog(
            id: "l1",
            petId: "p1",
            category: .vaccine,
            title: "Rabies",
            note: "old",
            date: Date().addingTimeInterval(1000),
            isResolved: false,
            completedDate: nil,
            nextDueDate: Date().addingTimeInterval(1000),
            recurrence: .yearly,
            value: nil,
            dosage: nil,
            timesPerDay: nil,
            reminderTimes: [Date()],
            durationDays: nil,
            medicationCourseStart: nil
        )

        let health = HealthServiceMock()
        health.logsByPetId["p1"] = [original]

        let notification = NotificationServiceMock()
        let reminder = ReminderSyncServiceMock()

        let (sut, _, _, _, _) = makeSUT(
            sourceLog: original,
            health: health,
            reminder: reminder,
            notification: notification
        )

        let newDate = Date().addingTimeInterval(86400 * 5)

        await sut.saveLogEdits(
            originalLog: original,
            newDate: newDate,
            newNote: "  new note ",
            valueString: "",
            dosage: ""
        )

        #expect(health.updateCalls.count == 1)
        let updated = health.updateCalls[0]
        #expect(updated.note == "new note")
        #expect(updated.nextDueDate == newDate)
        #expect(updated.reminderTimes == nil)

        #expect(notification.cancelCalls == ["l1"])
        #expect(reminder.scheduleCalls.count == 1)
        #expect(reminder.scheduleCalls[0].id == "l1")

        #expect(sut.state == .loaded)
    }

    @Test("saveLogEdits medication not resolved -> generates schedule, sets nextDueDate, updates dosage, schedules reminder")
    func saveLogEdits_medication_notResolved_generatesSchedule() async {
        let original = HealthLog(
            id: "m1",
            petId: "p1",
            category: .medication,
            title: "Antibiotic",
            note: nil,
            date: Date().addingTimeInterval(1000),
            isResolved: false,
            completedDate: nil,
            nextDueDate: Date().addingTimeInterval(1000),
            recurrence: .daily,
            value: nil,
            dosage: "old",
            timesPerDay: 2,
            reminderTimes: nil,
            durationDays: 7,
            medicationCourseStart: Date().startOfDay
        )

        let health = HealthServiceMock()
        health.logsByPetId["p1"] = [original]

        let notification = NotificationServiceMock()
        let reminder = ReminderSyncServiceMock()

        let (sut, _, _, _, _) = makeSUT(
            sourceLog: original,
            health: health,
            reminder: reminder,
            notification: notification
        )

        let newDate = Date().addingTimeInterval(3600 * 10)

        await sut.saveLogEdits(
            originalLog: original,
            newDate: newDate,
            newNote: "  hi ",
            valueString: "",
            dosage: "  5mg "
        )

        #expect(health.updateCalls.count == 1)
        let updated = health.updateCalls[0]
        #expect(updated.dosage == "5mg")
        #expect(updated.nextDueDate == newDate)
        #expect(updated.reminderTimes?.isEmpty == false)
        #expect(updated.reminderTimes?.count == 2)

        #expect(notification.cancelCalls == ["m1"])
        #expect(reminder.scheduleCalls.count == 1)
        #expect(reminder.scheduleCalls[0].id == "m1")
    }

    @Test("saveLogEdits weight updates value when parsable")
    func saveLogEdits_weight_updatesValue() async {
        let original = HealthLog(
            id: "w1",
            petId: "p1",
            category: .weight,
            title: "4.2 kg",
            note: nil,
            date: Date(),
            isResolved: true,
            completedDate: Date(),
            nextDueDate: nil,
            recurrence: nil,
            value: 4.2,
            dosage: nil,
            timesPerDay: nil,
            reminderTimes: nil,
            durationDays: nil,
            medicationCourseStart: nil
        )

        let health = HealthServiceMock()
        health.logsByPetId["p1"] = [original]

        let notification = NotificationServiceMock()
        let reminder = ReminderSyncServiceMock()

        let (sut, _, _, _, _) = makeSUT(
            sourceLog: original,
            health: health,
            reminder: reminder,
            notification: notification
        )

        let newDate = Date().addingTimeInterval(-3600)

        await sut.saveLogEdits(
            originalLog: original,
            newDate: newDate,
            newNote: "",
            valueString: "4.9",
            dosage: ""
        )

        #expect(health.updateCalls.count == 1)
        let updated = health.updateCalls[0]
        #expect(updated.value == 4.9)

        #expect(reminder.scheduleCalls.isEmpty)
    }

    @Test("saveLogEdits resolved log does not schedule reminder")
    func saveLogEdits_resolved_doesNotSchedule() async {
        let original = HealthLog(
            id: "r1",
            petId: "p1",
            category: .vaccine,
            title: "Rabies",
            note: nil,
            date: Date(),
            isResolved: true,
            completedDate: Date(),
            nextDueDate: nil,
            recurrence: .yearly,
            value: nil,
            dosage: nil,
            timesPerDay: nil,
            reminderTimes: nil,
            durationDays: nil,
            medicationCourseStart: nil
        )

        let health = HealthServiceMock()
        health.logsByPetId["p1"] = [original]

        let reminder = ReminderSyncServiceMock()
        let notification = NotificationServiceMock()

        let (sut, _, _, _, _) = makeSUT(
            sourceLog: original,
            health: health,
            reminder: reminder,
            notification: notification
        )

        await sut.saveLogEdits(
            originalLog: original,
            newDate: Date().addingTimeInterval(999),
            newNote: "x",
            valueString: "",
            dosage: ""
        )

        #expect(health.updateCalls.count == 1)
        #expect(notification.cancelCalls == ["r1"])
        #expect(reminder.scheduleCalls.isEmpty)
    }

    @Test("deleteLog cancels notification, deletes via service, refreshes")
    func deleteLog_deletes_andRefreshes() async {
        let log = HealthLog(
            id: "d1",
            petId: "p1",
            category: .vet,
            title: "Visit",
            note: nil,
            date: Date(),
            isResolved: false,
            completedDate: nil,
            nextDueDate: Date().addingTimeInterval(100),
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
        let (sut, _, _, _, _) = makeSUT(sourceLog: log, health: health, notification: notification)

        await sut.deleteLog(log)

        #expect(notification.cancelCalls == ["d1"])
        #expect(health.deleteCalls.count == 1)
        #expect(health.deleteCalls[0].petId == "p1")
        #expect(health.deleteCalls[0].logId == "d1")
        #expect(sut.state == .loaded)
    }

    @Test("resolveLog sets resolved fields, cancels notification, updates via service, refreshes")
    func resolveLog_marksResolved_updates_andCancels() async {
        let upcoming = HealthLog(
            id: "u1",
            petId: "p1",
            category: .vaccine,
            title: "Rabies",
            note: nil,
            date: Date(),
            isResolved: false,
            completedDate: nil,
            nextDueDate: Date().addingTimeInterval(100),
            recurrence: .yearly,
            value: nil,
            dosage: nil,
            timesPerDay: nil,
            reminderTimes: [Date()],
            durationDays: nil,
            medicationCourseStart: nil
        )

        let health = HealthServiceMock()
        health.logsByPetId["p1"] = [upcoming]

        let notification = NotificationServiceMock()
        let reminder = ReminderSyncServiceMock()

        let (sut, _, _, _, _) = makeSUT(
            sourceLog: upcoming,
            health: health,
            reminder: reminder,
            notification: notification
        )

        await sut.resolveLog(upcoming)

        #expect(health.updateCalls.count == 1)
        let updated = health.updateCalls[0]
        #expect(updated.isResolved == true)
        #expect(updated.completedDate != nil)
        #expect(updated.nextDueDate == nil)
        #expect(updated.reminderTimes == nil)

        #expect(notification.cancelCalls == ["u1"])
        #expect(sut.state == .loaded)
    }
}

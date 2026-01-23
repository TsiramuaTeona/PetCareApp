//
//  RemindersViewModelTests.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 23.01.26.
//

import Foundation
import Testing
@testable import PetCareApp

@Suite("RemindersViewModel")
@MainActor
struct RemindersViewModelTests {

    private func makeItem(id: String, category: LogCategory) -> ReminderItem {
        let log = HealthLog(
            id: id,
            petId: "p1",
            category: category,
            title: "T",
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

        return ReminderItem(
            petId: "p1",
            petName: "Luna",
            petPhoto: nil,
            log: log
        )
    }

    private func makeSUT(reminders: [ReminderItem]) -> RemindersViewModel {
        RemindersViewModel(reminders: reminders)
    }

    private func waitForFilterToFinish() async {
        try? await Task.sleep(nanoseconds: 1_000_000_000)
    }

    @Test("init -> filteredReminders equals input, selectedCategory nil, isLoading false")
    func init_setsInitialState() async {
        let items = [
            makeItem(id: "1", category: .vaccine),
            makeItem(id: "2", category: .vet)
        ]

        let sut = makeSUT(reminders: items)

        #expect(sut.filteredReminders.map(\.log.id) == ["1", "2"])
        #expect(sut.selectedCategory == nil)
        #expect(sut.isLoading == false)
    }

    @Test("categories -> excludes weight")
    func categories_excludesWeight() async {
        let sut = makeSUT(reminders: [])

        #expect(!sut.categories.contains(.weight))
        #expect(sut.categories.count == LogCategory.allCases.filter { $0 != .weight }.count)
    }

    @Test("selectCategory(nil) -> returns all reminders after delay")
    func selectCategory_nil_returnsAll() async {
        let items = [
            makeItem(id: "1", category: .vaccine),
            makeItem(id: "2", category: .vet),
            makeItem(id: "3", category: .medication)
        ]

        let sut = makeSUT(reminders: items)

        sut.selectCategory(nil)

        #expect(sut.isLoading == true)

        await waitForFilterToFinish()

        #expect(sut.isLoading == false)
        #expect(sut.selectedCategory == nil)
        #expect(sut.filteredReminders.map(\.log.id) == ["1", "2", "3"])
    }

    @Test("selectCategory(vaccine) -> filters only vaccine after delay")
    func selectCategory_filtersCorrectly() async {
        let items = [
            makeItem(id: "1", category: .vaccine),
            makeItem(id: "2", category: .vet),
            makeItem(id: "3", category: .vaccine)
        ]

        let sut = makeSUT(reminders: items)

        sut.selectCategory(.vaccine)

        #expect(sut.isLoading == true)
        #expect(sut.selectedCategory == .vaccine)

        await waitForFilterToFinish()

        #expect(sut.isLoading == false)
        #expect(sut.filteredReminders.map(\.log.id) == ["1", "3"])
    }

    @Test("selectCategory twice quickly -> final selection wins")
    func selectCategory_twice_finalWins() async {
        let items = [
            makeItem(id: "1", category: .vaccine),
            makeItem(id: "2", category: .vet),
            makeItem(id: "3", category: .vaccine),
            makeItem(id: "4", category: .vet)
        ]

        let sut = makeSUT(reminders: items)

        sut.selectCategory(.vaccine)
        sut.selectCategory(.vet)

        #expect(sut.selectedCategory == .vet)
        #expect(sut.isLoading == true)

        await waitForFilterToFinish()

        #expect(sut.isLoading == false)
        #expect(sut.filteredReminders.map(\.log.id) == ["2", "4"])
    }
}

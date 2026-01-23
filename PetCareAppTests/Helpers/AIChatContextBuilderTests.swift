//
//  AIChatContextBuilderTests.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 23.01.26.
//

import Foundation
import Testing

@testable import PetCareApp

@Suite("AIChatContextBuilder")
struct AIChatContextBuilderTests {

    @Test("build returns fallback when no pets")
    func emptyPetsFallback() {
        let out = AIChatContextBuilder.build(pets: [], logsByPetId: [:])
        #expect(out.contains("No pets available"))
    }

    @Test("build includes pet header and medical advice reminder")
    func includesSummary() {
        let pet = makePet(id: "p1", name: "Bella")
        let out = AIChatContextBuilder.build(
            pets: [pet],
            logsByPetId: ["p1": []]
        )

        #expect(out.contains("Household Pets Summary:"))
        #expect(out.contains("Pet: Bella"))
        #expect(out.contains("If user asks medical advice"))
    }

    @Test("includeResolved = false removes resolved history lines")
    func filtersResolved() {
        let pet = makePet(id: "p1", name: "Bella")

        var resolved = makeLog(
            petId: "p1",
            category: .weight,
            title: "Weigh-in",
            date: Date().addingTimeInterval(-3600)
        )
        resolved.isResolved = true

        let out = AIChatContextBuilder.build(
            pets: [pet],
            logsByPetId: ["p1": [resolved]],
            includeResolved: false
        )

        #expect(
            out.contains("no logs yet")
                || out.contains("Recent history") == false
                || out.contains("resolved=yes") == false
        )
        #expect(out.contains("resolved=yes") == false)
    }

    @Test("maxHistoryLinesPerPet adds truncation line when too many logs")
    func historyTruncation() {
        let pet = makePet(id: "p1", name: "Bella")
        let now = Date()

        let logs: [HealthLog] = (0..<10).map { index in
            makeLog(
                petId: "p1",
                category: .weight,
                title: "Log \(index)",
                date: now.addingTimeInterval(TimeInterval(-index * 3600))
            )
        }

        let out = AIChatContextBuilder.build(
            pets: [pet],
            logsByPetId: ["p1": logs],
            maxHistoryLinesPerPet: 3
        )

        #expect(out.contains("Recent history"))
        #expect(out.contains("(and") == true)
        #expect(out.contains("older items not shown") == true)
    }
}

extension AIChatContextBuilderTests {

    fileprivate func makePet(id: String, name: String) -> Pet {
        var pet = Pet(
            householdId: "h1",
            name: name,
            species: .cat,
            breed: nil,
            gender: .female,
            birthDate: DateFactory.make(year: 2023, month: 1, day: 1),
            color: nil,
            bio: nil,
            createdAt: Date()
        )
        
        pet.id = id
        return pet
    }

    fileprivate func makeLog(
        petId: String,
        category: LogCategory,
        title: String,
        date: Date
    ) -> HealthLog {
        HealthLog(
            petId: petId,
            category: category,
            title: title,
            note: nil,
            date: date,
            isResolved: false,
            completedDate: nil,
            nextDueDate: nil,
            recurrence: nil,
            value: 4.5,
            dosage: nil,
            timesPerDay: nil,
            reminderTimes: nil,
            durationDays: nil,
            medicationCourseStart: nil
        )
    }
}

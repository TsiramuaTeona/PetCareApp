//
//  MedicationSchedulerTests.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 23.01.26.
//

import Foundation
import Testing
@testable import PetCareApp

@Suite("MedicationScheduler")
struct MedicationSchedulerTests {

    @Test("generateSchedule frequency <= 0 defaults to 1")
    func generateScheduleDefaultsToOne() {
        let start = DateFactory.make(year: 2025, month: 1, day: 12, hour: 8, minute: 0)
        let times = MedicationScheduler.generateSchedule(start: start, frequency: 0)
        #expect(times.count == 1)
        #expect(DateFactory.hourMinute(times[0]).hour == 8)
        #expect(DateFactory.hourMinute(times[0]).minute == 0)
    }

    @Test("generateSchedule frequency 2 produces 12-hour spacing")
    func generateScheduleTwiceDaily() {
        let start = DateFactory.make(year: 2025, month: 1, day: 12, hour: 8, minute: 0)
        let times = MedicationScheduler.generateSchedule(start: start, frequency: 2)

        #expect(times.count == 2)
        #expect(DateFactory.hourMinute(times[0]).hour == 8)
        #expect(DateFactory.hourMinute(times[1]).hour == 20)
    }

    @Test("findNextDose returns the next time today when still upcoming")
    func findNextDoseToday() {
        let anchor1 = DateFactory.make(year: 2025, month: 1, day: 1, hour: 8, minute: 0)
        let anchor2 = DateFactory.make(year: 2025, month: 1, day: 1, hour: 20, minute: 0)

        let now = DateFactory.make(year: 2025, month: 2, day: 10, hour: 7, minute: 30)
        let next = MedicationScheduler.findNextDose(from: [anchor1, anchor2], now: now)

        #expect(next != nil)
        guard let next else { return }
        let hourMinute = DateFactory.hourMinute(next)
        #expect(hourMinute.hour == 8)
        #expect(hourMinute.minute == 0)
    }

    @Test("findNextDose returns tomorrow's first time if all times today passed")
    func findNextDoseTomorrow() {
        let anchor1 = DateFactory.make(year: 2025, month: 1, day: 1, hour: 8, minute: 0)
        let anchor2 = DateFactory.make(year: 2025, month: 1, day: 1, hour: 20, minute: 0)

        let now = DateFactory.make(year: 2025, month: 2, day: 10, hour: 22, minute: 0)
        let next = MedicationScheduler.findNextDose(from: [anchor1, anchor2], now: now)

        #expect(next != nil)
        guard let next else { return }
        let yearMonthDay = DateFactory.yearMonthDay(next)
        #expect(yearMonthDay.year == 2025)
        #expect(yearMonthDay.month == 2)
        #expect(yearMonthDay.day == 11)

        let hourMinute = DateFactory.hourMinute(next)
        #expect(hourMinute.hour == 8)
        #expect(hourMinute.minute == 0)
    }

    @Test("generateSchedule normalizes duplicates (unique hour/minute)")
    func normalizeDuplicates() {
        let day1 = DateFactory.make(year: 2025, month: 1, day: 1, hour: 8, minute: 0)
        let day2 = DateFactory.make(year: 2025, month: 1, day: 2, hour: 8, minute: 0)
        let next = MedicationScheduler.findNextDose(
            from: [day1, day2],
            now: DateFactory.make(year: 2025, month: 1, day: 3, hour: 7, minute: 0)
        )
        
        #expect(next != nil)
        guard let next else { return }
        #expect(DateFactory.hourMinute(next).hour == 8)
        #expect(DateFactory.hourMinute(next).minute == 0)
    }
}

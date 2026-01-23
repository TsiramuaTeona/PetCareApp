//
//  LogSchedulerTests.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 23.01.26.
//

import Foundation
import Testing
@testable import PetCareApp

@Suite("LogScheduler")
struct LogSchedulerTests {
    
    @Test("Medication next log advances by interval minutes and clears resolution/id fields")
    func medicationNextLog() {
        let start = DateFactory.make(year: 2025, month: 1, day: 1, hour: 8, minute: 0)
        
        var log = HealthLog(
            petId: "p1",
            category: .medication,
            title: "Antibiotic",
            note: nil,
            date: start,
            isResolved: true,
            completedDate: start,
            nextDueDate: start,
            recurrence: nil,
            value: nil,
            dosage: "1 pill",
            timesPerDay: 2,
            reminderTimes: nil,
            durationDays: nil,
            medicationCourseStart: start
        )
        
        log.id = "old-id"
        
        let next = LogScheduler.generateNextLog(currentLog: log)
        #expect(next != nil)
        guard let next = next else { return }
        
        #expect(next.id == nil)
        #expect(next.isResolved == false)
        #expect(next.completedDate == nil)
        
        let hourMinute = DateFactory.hourMinute(next.date)
        #expect(hourMinute.hour == 20)
        #expect(hourMinute.minute == 0)
        
        #expect(next.nextDueDate == next.date)
        #expect(next.medicationCourseStart == start)
    }
    
    @Test("Medication durationDays stops schedule after end of last day")
    func medicationDurationStops() {
        let start = DateFactory.make(year: 2025, month: 1, day: 1, hour: 8, minute: 0)

        var log = HealthLog(
            petId: "p1",
            category: .medication,
            title: "Course",
            note: nil,
            date: start,
            isResolved: false,
            completedDate: nil,
            nextDueDate: start,
            recurrence: nil,
            value: nil,
            dosage: nil,
            timesPerDay: 2,
            reminderTimes: nil,
            durationDays: 1,
            medicationCourseStart: start
        )
        
        let second = LogScheduler.generateNextLog(currentLog: log)
        #expect(second != nil)
        guard let second = second else { return }
        log = second
        
        let third = LogScheduler.generateNextLog(currentLog: log)
        #expect(third == nil)
    }
    
    @Test("Non-med recurrence uses recurrence rule and sets nextDueDate/date")
    func nonMedicationRecurrence() {
        let due = DateFactory.make(year: 2025, month: 1, day: 10, hour: 9, minute: 0)
        
        var log = HealthLog(
            petId: "p1",
            category: .vaccine,
            title: "Rabies shot",
            note: nil,
            date: due,
            isResolved: true,
            completedDate: due,
            nextDueDate: due,
            recurrence: .yearly,
            value: nil,
            dosage: nil,
            timesPerDay: nil,
            reminderTimes: nil,
            durationDays: nil,
            medicationCourseStart: nil
        )
        log.id = "old-id"
        
        let next = LogScheduler.generateNextLog(currentLog: log)
        #expect(next != nil)
        guard let next = next else { return }
        #expect(next.isResolved == false)
        #expect(next.completedDate == nil)
        #expect(next.id == nil)
        
        let yearMonthDay = DateFactory.yearMonthDay(next.date)
        #expect(yearMonthDay.year == 2026)
        #expect(yearMonthDay.month == 1)
        #expect(yearMonthDay.day == 10)
        
        #expect(next.nextDueDate == next.date)
    }
}

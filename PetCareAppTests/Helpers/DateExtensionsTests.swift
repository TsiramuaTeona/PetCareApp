//
//  DateExtensionsTests.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 23.01.26.
//

import Foundation
import Testing
@testable import PetCareApp

@Suite("Date+Extensions")
struct DateExtensionsTests {

    @Test("isToday / isTomorrow / isYesterday behave correctly")
    func relativeDayBooleans() {
        let now = Date()
        #expect(now.isToday == true)

        let tomorrow = now.adding(days: 1)
        #expect(tomorrow.isTomorrow == true)

        let yesterday = now.adding(days: -1)
        #expect(yesterday.isYesterday == true)
    }

    @Test("isInPast / isInFuture are consistent around now")
    func pastFutureChecks() {
        let now = Date()
        let past = now.addingTimeInterval(-2)
        let future = now.addingTimeInterval(2)

        #expect(past.isInPast == true)
        #expect(past.isInFuture == false)

        #expect(future.isInFuture == true)
        #expect(future.isInPast == false)
    }

    @Test("startOfDay and endOfDay span the same day")
    func startAndEndOfDay() {
        let calendar = Calendar.current
        let sample = DateFactory.make(year: 2025, month: 1, day: 12, hour: 15, minute: 20, second: 10, calendar: calendar)

        let start = sample.startOfDay
        let end = sample.endOfDay

        #expect(start <= sample)
        #expect(sample <= end)

        let expectedEnd = calendar.date(byAdding: DateComponents(day: 1, second: -1), to: start)
        #expect(end == expectedEnd)
    }

    @Test("adding(minutes/hours/days/months/years) changes the intended component")
    func addingUnits() {
        let base = DateFactory.make(year: 2025, month: 2, day: 10, hour: 10, minute: 0, second: 0)

        let plus90 = base.adding(minutes: 90)
        #expect(DateFactory.hourMinute(plus90).hour == 11)
        #expect(DateFactory.hourMinute(plus90).minute == 30)

        let plus3h = base.adding(hours: 3)
        #expect(DateFactory.hourMinute(plus3h).hour == 13)

        let plus2d = base.adding(days: 2)
        #expect(DateFactory.yearMonthDay(plus2d).day == 12)

        let plus1m = base.adding(months: 1)
        #expect(DateFactory.yearMonthDay(plus1m).month == 3)

        let plus1y = base.adding(years: 1)
        #expect(DateFactory.yearMonthDay(plus1y).year == 2026)
    }

    @Test("addingMonthsClamped clamps 31st -> last day of shorter month (non-leap year)")
    func addingMonthsClamped() {
        let jan31 = DateFactory.make(year: 2025, month: 1, day: 31, hour: 10, minute: 0, second: 0)
        let result = jan31.addingMonthsClamped(1)

        let yearMonthDay = DateFactory.yearMonthDay(result)
        #expect(yearMonthDay.year == 2025)
        #expect(yearMonthDay.month == 2)
        #expect(yearMonthDay.day == 28)

        // time should be preserved
        let hourMinute = DateFactory.hourMinute(result)
        #expect(hourMinute.hour == 10)
        #expect(hourMinute.minute == 0)
    }

    @Test("addingYearsClamped clamps Feb 29 -> Feb 28 in non-leap year")
    func addingYearsClamped() {
        let feb29 = DateFactory.make(year: 2024, month: 2, day: 29, hour: 9, minute: 15, second: 0)
        let result = feb29.addingYearsClamped(1)

        let yearMonthDay = DateFactory.yearMonthDay(result)
        #expect(yearMonthDay.year == 2025)
        #expect(yearMonthDay.month == 2)
        #expect(yearMonthDay.day == 28)
    }

    @Test("replaceDate keeps time but swaps the date portion")
    func replaceDate() {
        let timeSource = DateFactory.make(year: 2025, month: 1, day: 10, hour: 14, minute: 30, second: 15)
        let otherDate = DateFactory.make(year: 2025, month: 3, day: 5, hour: 1, minute: 2, second: 3)

        let result = timeSource.replaceDate(with: otherDate)

        let yearMonthDay = DateFactory.yearMonthDay(result)
        #expect(yearMonthDay.year == 2025)
        #expect(yearMonthDay.month == 3)
        #expect(yearMonthDay.day == 5)

        let time = Calendar.current.dateComponents([.hour, .minute, .second], from: result)
        #expect(time.hour == 14)
        #expect(time.minute == 30)
        #expect(time.second == 15)
    }

    @Test("relativeDayString returns Today/Yesterday/Tomorrow when applicable")
    func relativeDayString() {
        let now = Date()
        #expect(now.relativeDayString == "Today")
        #expect(now.adding(days: -1).relativeDayString == "Yesterday")
        #expect(now.adding(days: 1).relativeDayString == "Tomorrow")
    }

    @Test("ageDescription formats years+months and months-only")
    func ageDescription() {
        let calendar = Calendar.current
        let start = DateFactory.make(year: 2024, month: 1, day: 1, calendar: calendar)
        let end = DateFactory.make(year: 2025, month: 3, day: 1, calendar: calendar)

        let age = start.ageDescription(to: end)
        #expect(age.contains("1"))
        #expect(age.contains("y") || age.contains("year"))

        let startWithoutYear = DateFactory.make(year: 2025, month: 1, day: 1, calendar: calendar)
        let endWithoutYear = DateFactory.make(year: 2025, month: 4, day: 1, calendar: calendar)
        let ageWithoutYear = startWithoutYear.ageDescription(to: endWithoutYear)
        #expect(ageWithoutYear.contains("3"))
        #expect(ageWithoutYear.contains("month"))
    }
}

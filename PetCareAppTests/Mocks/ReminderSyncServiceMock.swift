//
//  ReminderSyncServiceMock.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 23.01.26.
//

import Foundation
@testable import PetCareApp

final class ReminderSyncServiceMock: ReminderSyncServiceProtocol {
    
    // MARK: - Properties

    private(set) var syncAllCalls: [String] = []
    private(set) var scheduleCalls: [HealthLog] = []
    private(set) var startListeningCalls: [String] = []
    private(set) var stopListeningCallsCount = 0

    // MARK: - Methods
    
    func syncAllReminders(forHousehold householdId: String) async {
        syncAllCalls.append(householdId)
    }

    func scheduleReminder(for log: HealthLog) async {
        scheduleCalls.append(log)
    }

    func startListeningForHousehold(_ householdId: String) async {
        startListeningCalls.append(householdId)
    }

    func stopListening() {
        stopListeningCallsCount += 1
    }
}

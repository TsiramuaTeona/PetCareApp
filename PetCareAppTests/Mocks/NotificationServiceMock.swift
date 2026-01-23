//
//  NotificationServiceMock.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 23.01.26.
//

import Foundation
import UserNotifications
@testable import PetCareApp

final class NotificationServiceMock: NotificationServiceProtocol {
    
    // MARK: - Properties
    
    private(set) var configureCalls = 0
    private(set) var requestAuthorizationCalls = 0
    var requestAuthorizationResult: Bool = true

    private(set) var authorizationStatusCalls = 0
    var statusToReturn: UNAuthorizationStatus = .notDetermined

    private(set) var scheduleCalls: [(logId: String?, petName: String)] = []
    private(set) var cancelCalls: [String?] = []
    private(set) var cancelAllCalls = 0

    // MARK: - Methods
    
    func configure() {
        configureCalls += 1
    }

    func requestAuthorization() async -> Bool {
        requestAuthorizationCalls += 1
        return requestAuthorizationResult
    }

    func authorizationStatus() async -> UNAuthorizationStatus {
        authorizationStatusCalls += 1
        return statusToReturn
    }

    func scheduleNotification(for log: HealthLog, petName: String) {
        scheduleCalls.append((log.id, petName))
    }

    func cancelNotification(for log: HealthLog) {
        cancelCalls.append(log.id)
    }

    func cancelAllPendingReminders() {
        cancelAllCalls += 1
    }
}

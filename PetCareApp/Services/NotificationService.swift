//
//  NotificationService.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 10.01.26.
//

import UIKit
import UserNotifications

protocol NotificationServiceProtocol: AnyObject {
    func configure()
    func requestAuthorization() async -> Bool
    func authorizationStatus() async -> UNAuthorizationStatus
    
    func scheduleNotification(for log: HealthLog, petName: String)
    func cancelNotification(for log: HealthLog)
    func cancelAllPendingReminders()
}

final class NotificationService: NSObject, NotificationServiceProtocol {
    
    // MARK: - Properties
    static let shared = NotificationService()
    private let center: UNUserNotificationCenter
    
    // MARK: - Initializer
    
    private override init() {
        self.center = .current()
        super.init()
    }
    
    // MARK: - Setup
    
    func configure() {
        center.delegate = self
    }
    
    // MARK: - Authorization
    
    func requestAuthorization() async -> Bool {
        do {
            return try await center.requestAuthorization(options: [.alert, .badge, .sound])
        } catch {
            return false
        }
    }
    
    func authorizationStatus() async -> UNAuthorizationStatus {
        let settings = await center.notificationSettings()
        return settings.authorizationStatus
    }
    
    // MARK: - Scheduling
    
    func scheduleNotification(for log: HealthLog, petName: String) {
        cancelNotification(for: log)
        
        guard
            let logId = log.id,
            !logId.isEmpty,
            !log.isResolved
        else { return }
        
        if let times = log.reminderTimes, !times.isEmpty {
            let now = Date()
            let next = MedicationScheduler.findNextDose(from: times, now: now)
            
            guard let next else { return }
            
            if log.isMedication, let duration = log.durationDays {
                let start = (log.medicationCourseStart ?? log.date).startOfDay
                let lastDay = start.adding(days: max(0, duration - 1))
                let end = lastDay.endOfDay
                guard next <= end else { return }
            }
            
            scheduleOne(
                identifier: logId,
                title: "\(petName): \(log.title)",
                body: notificationBody(for: log),
                triggerDate: next,
                repeats: false
            )
            return
        }
        
        if let dueDate = log.nextDueDate, dueDate > Date() {
            scheduleOne(
                identifier: logId,
                title: "\(petName): \(log.title)",
                body: notificationBody(for: log),
                triggerDate: dueDate,
                repeats: false
            )
        }
    }
    
    func cancelNotification(for log: HealthLog) {
        guard let logId = log.id else { return }
        
        var identifiers = [logId]
        identifiers += (0..<8).map { "\(logId)_\($0)" }
        
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
        center.removeDeliveredNotifications(withIdentifiers: identifiers)
    }
    
    func cancelAllPendingReminders() {
        center.removeAllPendingNotificationRequests()
        center.removeAllDeliveredNotifications()
    }
    
    // MARK: - Helpers
    
    private func scheduleOne(
        identifier: String,
        title: String,
        body: String,
        triggerDate: Date,
        repeats: Bool
    ) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let calendar = Calendar.current
        let components: DateComponents = repeats
        ? calendar.dateComponents([.hour, .minute], from: triggerDate)
        : calendar.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate)
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: components,
            repeats: repeats
        )
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )
        
        center.add(request)
    }
    
    private func notificationBody(for log: HealthLog) -> String {
        
        if let dosage = log.dosage, !dosage.isEmpty {
            return "Dosage: \(dosage)"
        }
        
        return "It's time for \(log.category.rawValue)"
    }
}

// MARK: - Foreground Presentation

extension NotificationService: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .sound, .badge]
    }
}

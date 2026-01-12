//
//  NotificationManager.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 10.01.26.
//


import UserNotifications
import UIKit

class NotificationManager {
    // MARK: - Singleton Instance
    
    static let shared = NotificationManager()
    
    // MARK: - Initializer
    
    func requestAuthorization() {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in }
    }
    
    func scheduleNotification(for log: HealthLog, petName: String) {
        cancelNotification(for: log)
        guard let logId = log.id, !log.isResolved else { return }
        
        if let times = log.reminderTimes, !times.isEmpty {
            for (index, time) in times.enumerated() {
                scheduleOne(
                    log: log,
                    petName: petName,
                    triggerDate: time,
                    identifier: "\(logId)-\(index)",
                    repeats: true
                )
            }
        } else if let dueDate = log.nextDueDate {
            scheduleOne(
                log: log,
                petName: petName,
                triggerDate: dueDate,
                identifier: logId,
                repeats: false
            )
        }
    }
    
    func cancelNotification(for log: HealthLog) {
        guard let id = log.id else { return }
        let identifiers = (0..<5).map { "\(id)-\($0)" } + [id]
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
    }
    
    func cancelAllPendingReminders() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    private func scheduleOne(log: HealthLog, petName: String, triggerDate: Date, identifier: String, repeats: Bool) {
        let content = UNMutableNotificationContent()
        content.title = "\(petName): \(log.title)"
        content.body = log.note ?? "It's time for \(log.category.rawValue)"
        content.sound = .default
        
        let calendar = Calendar.current
        let components: DateComponents
        
        if repeats {
            components = calendar.dateComponents([.hour, .minute], from: triggerDate)
        } else {
            components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate)
        }
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: repeats)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
}

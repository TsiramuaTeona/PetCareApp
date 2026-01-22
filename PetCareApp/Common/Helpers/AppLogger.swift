//
//  AppLogger.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 22.01.26.
//

import Foundation
import OSLog

enum AppLogger {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "PetCareApp"

    static let app = Logger(subsystem: subsystem, category: "app")
    static let services = Logger(subsystem: subsystem, category: "services")
    static let firestore = Logger(subsystem: subsystem, category: "firestore")
    static let notifications = Logger(subsystem: subsystem, category: "notifications")
    static let location = Logger(subsystem: subsystem, category: "location")
    static let map = Logger(subsystem: subsystem, category: "map")
    static let images = Logger(subsystem: subsystem, category: "images")
}

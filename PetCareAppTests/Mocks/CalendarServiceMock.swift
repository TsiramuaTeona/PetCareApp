//
//  CalendarServiceMock.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 23.01.26.
//

import Foundation
@testable import PetCareApp

final class CalendarServiceMock: CalendarServiceProtocol {
    
    // MARK: - Properties

    private(set) var addCalls: [(log: HealthLog, petName: String?)] = []
    var addError: Error?
    
    // MARK: - Methods

    func addHealthLogEvent(log: HealthLog, petName: String?) async throws {
        addCalls.append((log, petName))
        if let addError { throw addError }
    }
}

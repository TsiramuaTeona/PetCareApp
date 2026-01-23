//
//  UserServiceMock.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 23.01.26.
//

import Combine
import Foundation
@testable import PetCareApp

final class UserServiceMock: UserServiceProtocol {
    
    // MARK: - Properties

    var usersById: [String: UserProfile] = [:]
    private var householdIdSubjects: [String: CurrentValueSubject<String?, Never>] = [:]

    var createError: Error?
    var getError: Error?
    var updateProfileError: Error?
    var updateHouseholdError: Error?

    private(set) var createCalls: [UserProfile] = []
    private(set) var getCalls: [String] = []
    private(set) var updateProfileCalls: [(userId: String, fullName: String?, photoUrl: String?)] = []
    private(set) var updateHouseholdCalls: [(userId: String, householdId: String?)] = []
    private(set) var householdPublisherCalls: [String] = []

    // MARK: - Methods
    
    func createUserProfile(user: UserProfile) async throws {
        createCalls.append(user)
        if let createError { throw createError }
        usersById[user.id] = user
        subject(for: user.id).send(user.householdId)
    }

    func getUser(userId: String) async throws -> UserProfile {
        getCalls.append(userId)
        if let getError { throw getError }
        
        guard let user = usersById[userId] else {
            throw TestError.message("UserServiceMock missing userId=\(userId)")
        }
        
        return user
    }

    func updateUserProfile(userId: String, fullName: String?, photoUrl: String?) async throws {
        updateProfileCalls.append((userId, fullName, photoUrl))
        if let updateProfileError { throw updateProfileError }
        guard var user = usersById[userId] else { return }

        if let fullName, !fullName.isEmptyOrWhitespace { user.fullName = fullName.trimmed }
        if let photoUrl, !photoUrl.isEmptyOrWhitespace {
            user.photoUrl = photoUrl.trimmed
        } else {
            user.photoUrl = nil
        }
        usersById[userId] = user
    }

    func updateUserHousehold(userId: String, householdId: String?) async throws {
        updateHouseholdCalls.append((userId, householdId))
        if let updateHouseholdError { throw updateHouseholdError }
        guard var user = usersById[userId] else { return }

        let cleaned = householdId?.trimmed
        user.householdId = (cleaned?.isEmpty == false) ? cleaned : nil
        usersById[userId] = user
        subject(for: userId).send(user.householdId)
    }

    func householdIdPublisher(userId: String) -> AnyPublisher<String?, Never> {
        householdPublisherCalls.append(userId)
        return subject(for: userId)
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    func pushHouseholdId(userId: String, _ householdId: String?) {
        subject(for: userId).send(householdId)
    }

    private func subject(for userId: String) -> CurrentValueSubject<String?, Never> {
        if let subject = householdIdSubjects[userId] { return subject }
        let subject = CurrentValueSubject<String?, Never>(usersById[userId]?.householdId)
        householdIdSubjects[userId] = subject
        return subject
    }
}

//
//  AuthServiceMock.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 23.01.26.
//

import Combine
import Foundation
import FirebaseAuth
@testable import PetCareApp

final class AuthServiceMock: AuthServiceProtocol {

    // MARK: - Properties

    var currentUser: User? = nil
    var currentUserId: String? = nil

    private let subject: CurrentValueSubject<User?, Never>

    var userSessionPublisher: AnyPublisher<User?, Never> {
        subject.eraseToAnyPublisher()
    }

    // MARK: - Call tracking

    private(set) var signInCalls: [(email: String, password: String)] = []
    var signInError: Error?

    private(set) var signInWithGoogleCalls: [(idToken: String, accessToken: String)] = []
    var signInWithGoogleResult: Bool = false
    var signInWithGoogleError: Error?

    private(set) var signUpCalls: [(email: String, password: String)] = []
    var signUpError: Error?

    private(set) var signOutCallsCount: Int = 0
    var signOutError: Error?

    private(set) var resetPasswordCalls: [String] = []
    var resetPasswordError: Error?

    // MARK: - Initializer

    init(initialUser: User? = nil) {
        self.subject = CurrentValueSubject<User?, Never>(initialUser)
        self.currentUser = initialUser
        self.currentUserId = initialUser?.uid
    }

    // MARK: - Helpers

    func sendSession(_ user: User?) {
        currentUser = user
        currentUserId = user?.uid
        subject.send(user)
    }

    // MARK: - Protocol

    func signIn(email: String, password: String) async throws {
        signInCalls.append((email, password))
        if let signInError { throw signInError }
    }

    func signInWithGoogle(idToken: String, accessToken: String) async throws -> Bool {
        signInWithGoogleCalls.append((idToken, accessToken))
        if let signInWithGoogleError { throw signInWithGoogleError }
        return signInWithGoogleResult
    }

    func signUp(email: String, password: String) async throws {
        signUpCalls.append((email, password))
        if let signUpError { throw signUpError }
    }

    func signOut() throws {
        signOutCallsCount += 1
        if let signOutError { throw signOutError }
    }

    func resetPassword(email: String) async throws {
        resetPasswordCalls.append(email)
        if let resetPasswordError { throw resetPasswordError }
    }
}

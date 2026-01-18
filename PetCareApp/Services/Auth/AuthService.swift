//
//  AuthService.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 03.01.26.
//

import Combine
import FirebaseAuth
import Foundation
import GoogleSignIn

// MARK: - AuthServiceProtocol

protocol AuthServiceProtocol {
    var currentUser: User? { get }
    var currentUserId: String? { get }
    
    var userSessionPublisher: AnyPublisher<User?, Never> { get }
    
    func signIn(email: String, password: String) async throws
    func signInWithGoogle(idToken: String, accessToken: String) async throws -> Bool
    func signUp(email: String, password: String) async throws
    func signOut() throws
    func resetPassword(email: String) async throws
}

// MARK: - AuthService

final class AuthService: AuthServiceProtocol {
    // MARK: - Properties
    
    var userSessionPublisher: AnyPublisher<User?, Never> {
        userSessionSubject.eraseToAnyPublisher()
    }
    
    private let userSessionSubject = CurrentValueSubject<User?, Never>(Auth.auth().currentUser)
    private var handle: AuthStateDidChangeListenerHandle?
    
    var currentUser: User? { Auth.auth().currentUser }
    var currentUserId: String? { Auth.auth().currentUser?.uid }
    
    // MARK: - Initializer
    
    init() {
        handle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.userSessionSubject.send(user)
        }
    }
    
    // MARK: - Methods
    
    deinit {
        if let handle = handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
    // MARK: - Public Methods
    
    func signIn(email: String, password: String) async throws {
        do {
            try await Auth.auth().signIn(withEmail: email, password: password)
        } catch {
            throw mapFirebaseError(error)
        }
    }
    
    func signInWithGoogle(idToken: String, accessToken: String) async throws -> Bool {
        let credential = GoogleAuthProvider.credential(
            withIDToken: idToken,
            accessToken: accessToken
        )
        
        do {
            let authResult = try await Auth.auth().signIn(with: credential)
            
            return authResult.additionalUserInfo?.isNewUser ?? false
        } catch {
            throw mapFirebaseError(error)
        }
    }
    
    func signUp(email: String, password: String) async throws {
        do {
            try await Auth.auth().createUser(
                withEmail: email,
                password: password
            )
        } catch {
            throw mapFirebaseError(error)
        }
    }
    
    func signOut() throws {
        do {
            try Auth.auth().signOut()
            GIDSignIn.sharedInstance.signOut()
        } catch {
            throw AuthError.unknown("Failed to sign out.")
        }
    }
    
    func resetPassword(email: String) async throws {
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
        } catch {
            throw mapFirebaseError(error)
        }
    }
    
    // MARK: - Private Methods
    
    private func mapFirebaseError(_ error: Error) -> AuthError {
        guard let nsError = error as NSError? else {
            return .unknown(error.localizedDescription)
        }
        
        guard let errorCode = AuthErrorCode(rawValue: nsError.code) else {
            return .unknown(nsError.localizedDescription)
        }
        
        switch errorCode {
        case .invalidEmail:
            return .invalidEmail
        case .weakPassword:
            return .weakPassword
        case .invalidCredential:
            return .invalidCredential
        case .userNotFound:
            return .userNotFound
        case .emailAlreadyInUse:
            return .emailAlreadyInUse
        default:
            return .unknown(nsError.localizedDescription)
        }
    }
}

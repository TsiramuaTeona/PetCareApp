//
//  LoginViewModel.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 03.01.26.
//

import Combine
import Foundation

enum LoginField: Hashable {
    case email, password
}

@MainActor
final class LoginViewModel: ObservableObject {
    // MARK: - Properties
    
    @Published var email = "" {
        didSet {
            clearError(for: .email)
        }
    }
    
    @Published var password = "" {
        didSet {
            clearError(for: .password)
        }
    }
    
    @Published var fieldErrors: [LoginField: AuthError] = [:]
    @Published var isLoading = false
    @Published var formError: String?
    
    private let authService: AuthServiceProtocol
    
    var onGoogleSignInRequested: (() -> Void)?
    
    // MARK: - Initializer
    
    init(authService: AuthServiceProtocol) {
        self.authService = authService
    }
    
    // MARK: - Methods
    
    func login() async {
        formError = nil
        guard validateForm() else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await authService.signIn(email: email, password: password)
        } catch {
            formError = error.localizedDescription
        }
    }
    
    func googleButtonTapped() {
        formError = nil
        isLoading = true
        onGoogleSignInRequested?()
    }
    
    func handleGoogleSignInResult(_ result: Result<Void, Error>) {
        isLoading = false
        
        switch result {
        case .success:
            break
        case .failure(_):
            formError = AuthError.googleSignCancelled.localizedDescription
        }
    }
    
    private func validateForm() -> Bool {
        if let error = FieldValidator.email(email) {
            fieldErrors[.email] = error
        }
        
        if let error = FieldValidator.required(password) {
            fieldErrors[.password] = error
        }
        
        return fieldErrors.isEmpty
    }
    
    private func clearError(for field: LoginField) {
        fieldErrors[field] = nil
        fieldErrors.removeValue(forKey: field)
        formError = nil
    }
}

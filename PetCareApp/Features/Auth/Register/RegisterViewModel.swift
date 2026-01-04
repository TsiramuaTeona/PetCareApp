//
//  RegisterViewModel.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 03.01.26.
//


import Foundation
import Combine

enum RegisterField: Hashable {
    case email, password, confirmPassword
}

@MainActor
final class RegisterViewModel: ObservableObject {
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
    
    @Published var confirmPassword = "" {
        didSet {
            clearError(for: .confirmPassword)
        }
    }
    
    @Published var showSuccessAlert: Bool = false
    @Published var fieldErrors: [RegisterField: AuthError] = [:]
    @Published var isLoading = false
    @Published var formError: String?
    
    private let authService: AuthServiceProtocol
    
    // MARK: - Initializer
    
    init(authService: AuthServiceProtocol) {
        self.authService = authService
    }
    
    // MARK: - Methods
    
    func register() async {
        formError = nil
        guard validateForm() else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await authService.signUp(email: email, password: password)
            showSuccessAlert = true
        } catch {
            formError = error.localizedDescription
        }
    }
    
    private func validateForm() -> Bool {
        if let error = FieldValidator.email(email) {
            fieldErrors[.email] = error
        }
        
        if let error = FieldValidator.password(password) {
            fieldErrors[.password] = error
        }
        
        if password != confirmPassword {
            fieldErrors[.confirmPassword] = AuthError.passwordsDontMatch
        }
        
        return fieldErrors.isEmpty
    }
    
    private func clearError(for field: RegisterField) {
        fieldErrors[field] = nil
        fieldErrors.removeValue(forKey: field)
        formError = nil
    }
}

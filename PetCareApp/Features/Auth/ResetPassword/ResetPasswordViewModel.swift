//
//  ResetPasswordViewModel.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 03.01.26.
//


import Foundation
import Combine

@MainActor
final class ResetPasswordViewModel: ObservableObject {
    // MARK: - Properties
    
    @Published var email = ""
    @Published var isLoading: Bool = false
    @Published var showSuccessAlert: Bool = false
    @Published var errorMessage: String?
    
    private let authService: AuthServiceProtocol
    
    // MARK: - Initializer
    
    init(authService: AuthServiceProtocol) {
        self.authService = authService
    }
    
    // MARK: - Methods
    
    func resetPassword() async {
        errorMessage = nil
        
        if let error = FieldValidator.email(email) {
            errorMessage = error.localizedDescription
            return
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await authService.resetPassword(email: email)
            showSuccessAlert = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

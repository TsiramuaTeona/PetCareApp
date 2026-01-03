//
//  LoginViewModel.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 03.01.26.
//


import Foundation
import Combine

final class LoginViewModel: ObservableObject {
    // MARK: - Properties
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let authService: AuthServiceProtocol
    let loginSucceeded = PassthroughSubject<Void, Never>()
    
    var onGoogleSignInRequested: (() -> Void)?
    
    // MARK: - Initializer
    
    init(authService: AuthServiceProtocol) {
        self.authService = authService
    }
    
    // MARK: - Methods
    
    func googleButtonTapped() {
        isLoading = true
        errorMessage = nil
        onGoogleSignInRequested?()
    }
    
    func handleGoogleSignInResult(_ result: Result<Void, Error>) {
        isLoading = false
        
        switch result {
        case .success:
            loginSucceeded.send()
        case .failure(let error):
            errorMessage = error.localizedDescription
        }
    }
}

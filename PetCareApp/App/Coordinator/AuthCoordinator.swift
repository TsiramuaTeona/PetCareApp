//
//  AuthCoordinator.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 03.01.26.
//


import UIKit
import SwiftUI
import FirebaseCore
import FirebaseAuth
import GoogleSignIn
import Combine

final class AuthCoordinator: Coordinator {
    // MARK: - Properties
    
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    private let container: AppDIContainer
    
    private var subscriptions = Set<AnyCancellable>()
    
    var onFinish: (() -> Void)?
    
    // MARK: - Initializer
    
    init(
        navigationController: UINavigationController,
        container: AppDIContainer
    ) {
        self.navigationController = navigationController
        self.container = container
    }
    
    // MARK: - Public Methods
    
    func start() {
        showLoginFlow()
    }
    
    func handle(_ destination: Destination) {
        switch destination {
        case .register:
            showRegisterView()
        case .resetPassword:
            showResetPasswordView()
        default:
            break
        }
    }
    
    // MARK: - Private Methods
    
    private func showLoginFlow() {
        let viewModel = container.makeLoginViewModel()
        
        viewModel.onGoogleSignInRequested = { [weak self, weak viewModel] in
            Task {
                await self?.performGoogleSignIn(viewModel: viewModel)
            }
        }
        
        viewModel.loginSucceeded
            .sink { [weak self] in
                self?.onFinish?()
            }
            .store(in: &subscriptions)
        
        let view = LoginView(viewModel: viewModel)
            .environment(\.navigate) { [weak self] destination in
                self?.handle(destination)
            }
        
        let viewController = UIHostingController(rootView: view)
        navigationController.setViewControllers([viewController], animated: false)
        
        navigationController.navigationBar.isHidden = true
    }
    
    private func showRegisterView() {
        let viewModel = container.makeRegisterViewModel()
        let view = RegisterView(viewModel: viewModel)
        let viewController = UIHostingController(rootView: view)
        navigationController.pushViewController(viewController, animated: true)
    }
    
    private func showResetPasswordView() {
        let viewModel = container.makeResetPasswordViewModel()
        let view = ResetPasswordView(viewModel: viewModel)
        let viewController = UIHostingController(rootView: view)
        navigationController.pushViewController(viewController, animated: true)
    }
    
    @MainActor
    private func performGoogleSignIn(viewModel: LoginViewModel?) async {
        guard
            let viewModel,
            let clientID = FirebaseApp.app()?.options.clientID
        else { return }
        
        let presenter = navigationController.topViewController ?? navigationController
        
        do {
            let config = GIDConfiguration(clientID: clientID)
            GIDSignIn.sharedInstance.configuration = config
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: presenter)
            
            guard let idToken = result.user.idToken?.tokenString else {
                throw AuthError.unknown("Missing ID token")
            }
            let accessToken = result.user.accessToken.tokenString
            
            let isNewUser = try await container.authService.signInWithGoogle(
                idToken: idToken,
                accessToken: accessToken
            )
            
            if isNewUser {
                try await createGoogleUserProfile()
            }
            
            viewModel.handleGoogleSignInResult(.success(()))
            
        } catch {
            viewModel.handleGoogleSignInResult(.failure(error))
        }
    }
    
    private func createGoogleUserProfile() async throws {
        guard let firebaseUser = Auth.auth().currentUser else { return }
        
        let newProfile = UserProfile(
            id: firebaseUser.uid,
            email: firebaseUser.email ?? "",
            fullName: firebaseUser.displayName,
            householdId: nil,
            createdAt: Date()
        )
        
        try await container.userService.createUserProfile(user: newProfile)
    }
}

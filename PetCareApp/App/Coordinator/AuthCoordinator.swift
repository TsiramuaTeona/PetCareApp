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

final class AuthCoordinator: Coordinator {
    // MARK: - Properties
    
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    
    private let container: AppDIContainer
    
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
            guard let self, let viewModel else { return }
            Task { [weak self] in
                await self?.performGoogleSignIn(viewModel: viewModel)
            }
        }
        
        let view = LoginView(viewModel: viewModel)
            .environment(\.navigate) { [weak self] destination in
                self?.handle(destination)
            }
        
        let viewController = UIHostingController(rootView: view)
        
        navigationController.setViewControllers([viewController], animated: false)
        navigationController.setNavigationBarHidden(true, animated: false)
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
    private func performGoogleSignIn(viewModel: LoginViewModel) async {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            viewModel.handleGoogleSignInResult(.failure(AuthError.unknown("Missing Firebase clientID")))
            return
        }
        
        let presenter = topMostPresenter()
        
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
    
    private func topMostPresenter() -> UIViewController {
        var presenter: UIViewController = navigationController
        while let presented = presenter.presentedViewController {
            presenter = presented
        }
        return presenter
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

//
//  AuthCoordinator.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 03.01.26.
//


import UIKit
import SwiftUI
import FirebaseCore
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
    
    // MARK: - Methods
    
    func start() {
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
        let viewController = UIHostingController(rootView: view)
        
        navigationController.setViewControllers([viewController], animated: false)
    }
    
    @MainActor
    private func performGoogleSignIn(viewModel: LoginViewModel?) async {
        guard
            let viewModel,
            let clientID = FirebaseApp.app()?.options.clientID,
            let rootViewController = navigationController.viewControllers.first
        else { return }
        
        do {
            let config = GIDConfiguration(clientID: clientID)
            GIDSignIn.sharedInstance.configuration = config
            
            let result = try await GIDSignIn.sharedInstance.signIn(
                withPresenting: rootViewController
            )
            
            guard let idToken = result.user.idToken?.tokenString else {
                throw AuthError.unknown("Missing ID token")
            }
            
            let accessToken = result.user.accessToken.tokenString
            
            try await container.authService.signInWithGoogle(
                idToken: idToken,
                accessToken: accessToken
            )
            
            viewModel.handleGoogleSignInResult(.success(()))
            
        } catch {
            viewModel.handleGoogleSignInResult(.failure(error))
        }
    }
}

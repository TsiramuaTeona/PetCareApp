//
//  AppCoordinator.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 03.01.26.
//


import UIKit
import Combine

final class AppCoordinator: Coordinator {
    // MARK: - Flow State
    
    private enum Flow {
        case auth
        case main
    }
    
    private var currentFlow: Flow?
    
    // MARK: - Properties
    
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    private let window: UIWindow
    
    private let container: AppDIContainer
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initializer
    
    init(
        window: UIWindow,
        container: AppDIContainer
    ) {
        self.window = window
        self.navigationController = UINavigationController()
        self.container = container
    }
    
    // MARK: - Public Methods
    
    func start() {
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        
        observeAuthState()
    }
    
    // MARK: - Private Methods
    
    private func observeAuthState() {
        container.authService.userSessionPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                guard let self else { return }
                
                if user != nil {
                    self.showMainFlowIfNeeded()
                } else {
                    self.showAuthFlowIfNeeded()
                }
            }
            .store(in: &cancellables)
    }
    
    private func showAuthFlowIfNeeded() {
        guard currentFlow != .auth else { return }
        currentFlow = .auth
        showAuthFlow()
    }
    
    private func showMainFlowIfNeeded() {
        guard currentFlow != .main else { return }
        currentFlow = .main
        showMainFlow()
    }
    
    private func showAuthFlow() {
        childCoordinators.removeAll()
        
        let authCoordinator = AuthCoordinator(
            navigationController: navigationController,
            container: container
        )
        
        childCoordinators.append(authCoordinator)
        authCoordinator.start()
    }
    
    private func showMainFlow() {
        childCoordinators.removeAll()
        
        let mainCoordinator = MainTabCoordinator(
            navigationController: navigationController,
            container: container
        )
        
        childCoordinators.append(mainCoordinator)
        mainCoordinator.start()
    }
}

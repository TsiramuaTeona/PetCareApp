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
    private let notificationManager = NotificationManager.shared
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initializer
    
    init(window: UIWindow, container: AppDIContainer) {
        self.window = window
        self.container = container
        self.navigationController = UINavigationController()
    }
    
    // MARK: - Public Methods
    
    func start() {
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        
        Task {
            await notificationManager.requestAuthorization()
        }
        
        observeAuthState()
    }
    
    func stop() {
        cancellables.removeAll()
        clearChildren()
    }
    
    // MARK: - Private Methods
    
    private func observeAuthState() {
        container.authService.userSessionPublisher
            .map { $0 != nil }
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoggedIn in
                guard let self else { return }
                self.switchToFlow(isLoggedIn ? .main : .auth)
            }
            .store(in: &cancellables)
    }
    
    private func switchToFlow(_ flow: Flow) {
        guard currentFlow != flow else { return }
        currentFlow = flow
        
        navigationController.dismiss(animated: false)
        
        navigationController.setViewControllers([], animated: false)
        
        clearChildren()
        
        switch flow {
        case .auth:
            let authCoordinator = AuthCoordinator(
                navigationController: navigationController,
                container: container
            )
            childCoordinators.append(authCoordinator)
            authCoordinator.start()
            
        case .main:
            let mainCoordinator = MainTabCoordinator(
                navigationController: navigationController,
                container: container
            )
            childCoordinators.append(mainCoordinator)
            mainCoordinator.start()
        }
    }
    
    private func clearChildren() {
        childCoordinators.forEach { $0.stop() }
        childCoordinators.removeAll()
    }
}

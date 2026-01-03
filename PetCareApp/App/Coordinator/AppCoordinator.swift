//
//  AppCoordinator.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 03.01.26.
//


import UIKit

final class AppCoordinator: Coordinator {
    // MARK: - Properties
    
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    private let window: UIWindow
    
    private let container: AppDIContainer
    
    // MARK: - Initializer
    
    init(
        window: UIWindow,
        container: AppDIContainer
    ) {
        self.window = window
        self.navigationController = UINavigationController()
        self.container = container
    }
    
    // MARK: - Methods
    
    func start() {
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        
        if container.authService.currentUserId == nil {
            handle(.login)
        } else {
            handle(.mainTabs)
        }
    }
    
    func handle(_ destination: Destination) {
        switch destination {
            
        case .login:
            let authCoordinator = AuthCoordinator(navigationController: navigationController, container: container)
            authCoordinator.onFinish = { [weak self] in
                self?.childDidFinish(authCoordinator)
                self?.handle(.mainTabs)
            }
            childCoordinators.append(authCoordinator)
            authCoordinator.start()
            
        case .mainTabs:
            navigationController.viewControllers = []
            
            let mainTabCoordinator = MainTabCoordinator(navigationController: navigationController, container: container)
            childCoordinators.append(mainTabCoordinator)
            mainTabCoordinator.start()
            
        default:
            break
        }
    }
}

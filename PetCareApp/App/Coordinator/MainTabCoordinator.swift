//
//  MainTabCoordinator.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 03.01.26.
//


import UIKit
import SwiftUI

final class MainTabCoordinator: Coordinator {
    // MARK: - Properties
    
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    
    private let container: AppDIContainer
    
    private let tabBarController = UITabBarController()
    
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
        setupTabs()
        navigationController.setViewControllers([tabBarController], animated: true)
        navigationController.isNavigationBarHidden = true
    }
    
    private func setupTabs() {
        let controllers = MainTab.allCases.map { tab -> UINavigationController in
            let navigation = UINavigationController()
            
            navigation.tabBarItem = UITabBarItem(
                title: tab.title,
                image: tab.icon,
                tag: tab.rawValue
            )
            
            let rootViewController = rootViewController(for: tab)
            navigation.setViewControllers([rootViewController], animated: false)
            
            return navigation
        }
        
        tabBarController.viewControllers = controllers
    }
    
    private func rootViewController(for tab: MainTab) -> UIViewController {
        switch tab {
        case .home:
            let view = HomeView()
                .environment(\.navigate) { [weak self] destination in
                    self?.handle(destination)
                }
            return UIHostingController(rootView: view)
            
        case .map:
            return MapViewController()
            
        case .shop:
            let view = ShopView()
                .environment(\.navigate) { [weak self] destination in
                    self?.handle(destination)
                }
            return UIHostingController(rootView: view)
        }
    }
    
    // MARK: - Navigation Handling Method
    
    func handle(_ destination: Destination) {
        guard let currentNavigation = tabBarController.selectedViewController as? UINavigationController else { return }
        
        switch destination {
        case .petDetails(let petId):
            let view = PetDetailsView(petId: petId)
                .environment(\.navigate) { [weak self] destination in
                    self?.handle(destination)
                }
            let viewController = UIHostingController(rootView: view)
            currentNavigation.pushViewController(viewController, animated: true)
            
        case .scanner(let onScan):
            let scannerViewController = ScannerViewController(
                //                onScan: onScan
            )
            currentNavigation.present(scannerViewController, animated: true)
            
        case .selectTab(let tab):
            tabBarController.selectedIndex = tab.rawValue
            
        default:
            break
        }
    }
}

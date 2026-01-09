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
    
    // MARK: - Public Methods
    
    func start() {
        setupTabs()
        navigationController.setViewControllers([tabBarController], animated: true)
        navigationController.isNavigationBarHidden = true
    }
    
    func handle(_ destination: Destination) {
        switch destination {
        case .petDetails(let pet):
            showPetDetails(pet: pet)
        case .addPet(let householdId):
            showAddPet(householdId: householdId)
        case .editPet(let pet, let onSave):
            showEditPet(pet: pet, onSave: onSave)
        case .scanner(let onScan):
            showScanner(onScan: onScan)
        case .selectTab(let tab):
            tabBarController.selectedIndex = tab.rawValue
        default:
            break
        }
    }
    
    // MARK: - Private Methods
    
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
            let viewModel = container.makeHomeViewModel()
            let view = HomeView(viewModel: viewModel)
                .environment(\.navigate) { [weak self] destination in
                    self?.handle(destination)
                }
            return UIHostingController(rootView: view)
            
        case .map:
            let viewModel = container.makeMapViewModel()
            return MapViewController(viewModel: viewModel, locationService: container.locationService)
            
        case .shop:
            let view = ShopView()
                .environment(\.navigate) { [weak self] destination in
                    self?.handle(destination)
                }
            return UIHostingController(rootView: view)
            
        case .profile:
            let viewModel = container.makeProfileViewModel()
            let view = ProfileView(viewModel: viewModel)
                .environment(\.navigate) { [weak self] destination in
                    self?.handle(destination)
                }
            return UIHostingController(rootView: view)
        }
    }
    
    private func showPetDetails(pet: Pet) {
        guard let currentNavigation = tabBarController.selectedViewController as? UINavigationController else { return }
        
        let viewModel = container.makePetDetailsViewModel(pet: pet)
        let view = PetDetailsView(viewModel: viewModel)
            .environment(\.navigate) { [weak self] destination in
                self?.handle(destination)
            }
        let viewController = UIHostingController(rootView: view)
        
        viewController.hidesBottomBarWhenPushed = true
        currentNavigation.pushViewController(viewController, animated: true)
    }
    
    private func showAddPet(householdId: String) {
        guard let currentNavigation = tabBarController.selectedViewController as? UINavigationController else { return }
        
        let viewModel = container.makeAddPetViewModel(householdId: householdId)
        let view = AddPetView(viewModel: viewModel)
        
        let viewController = UIHostingController(rootView: view)
        viewController.hidesBottomBarWhenPushed = true
        currentNavigation.pushViewController(viewController, animated: true)
    }
    
    private func showEditPet(pet: Pet, onSave: @escaping (Pet) -> Void) {
        guard let currentNavigation = tabBarController.selectedViewController as? UINavigationController else { return }
        
        let viewModel = container.makeEditPetViewModel(pet: pet)
        let view = EditPetView(
            viewModel: viewModel,
            onSave: onSave
        )
        
        let viewController = UIHostingController(rootView: view)
        currentNavigation.present(viewController, animated: true)
    }
    
    private func showScanner(onScan: @escaping (String) -> Void) {
        guard let currentNavigation = tabBarController.selectedViewController as? UINavigationController else { return }
        
        let scannerViewController = ScannerViewController(
            //                onScan: onScan
        )
        currentNavigation.present(scannerViewController, animated: true)
    }
}

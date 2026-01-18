//
//  MainTabCoordinator.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 03.01.26.
//

import SwiftUI
import UIKit

final class MainTabCoordinator: Coordinator {
    // MARK: - Properties
    
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    
    private let container: AppDIContainer
    private let tabBarController = UITabBarController()
    
    private var tabNavigations: [MainTab: UINavigationController] = [:]
    
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
        navigationController.setViewControllers(
            [tabBarController],
            animated: false
        )
        navigationController.setNavigationBarHidden(true, animated: false)
    }
    
    func handle(_ destination: Destination) {
        switch destination {
        case .petDetails(let pet):
            showPetDetails(pet: pet)
            
        case .addPet(let householdId):
            showAddPet(householdId: householdId)
            
        case .editPet(let pet, let onSave):
            showEditPet(pet: pet, onSave: onSave)
            
        case .addHealthLog(let petId, let category, let onSave):
            showAddHealthLog(petId: petId, category: category, onSave: onSave)
            
        case .logDetails(let petId, let petName, let log):
            showLogDetails(petId: petId, petName: petName, log: log)
            
        case .remindersList(let items):
            showRemindersList(items: items)
            
        case .selectTab(let tab):
            tabBarController.selectedIndex = tab.rawValue
            
        default:
            break
        }
    }
    
    // MARK: - Private Methods
    
    private func setupTabs() {
        let controllers = MainTab.allCases.map {
            tab -> UINavigationController in
            let nav = UINavigationController()
            nav.tabBarItem = UITabBarItem(
                title: tab.title,
                image: tab.icon,
                tag: tab.rawValue
            )
            
            let root = rootViewController(for: tab)
            nav.setViewControllers([root], animated: false)
            
            tabNavigations[tab] = nav
            return nav
        }
        
        tabBarController.viewControllers = controllers
    }
    
    private func currentTabNavigation() -> UINavigationController? {
        tabBarController.selectedViewController as? UINavigationController
    }
    
    private func hostingController<Content: View>(
        _ view: Content,
        hidesBottomBarWhenPushed: Bool = false
    ) -> UIViewController {
        let viewController = UIHostingController(rootView: view)
        viewController.hidesBottomBarWhenPushed = hidesBottomBarWhenPushed
        return viewController
    }
    
    private func rootViewController(for tab: MainTab) -> UIViewController {
        switch tab {
        case .home:
            let viewModel = container.makeHomeViewModel()
            let view = HomeView(viewModel: viewModel)
                .environment(\.navigate) { [weak self] destination in
                    self?.handle(destination)
                }
            return hostingController(view)
            
        case .map:
            let viewModel = container.makeMapViewModel()
            return MapViewController(
                viewModel: viewModel,
                locationService: container.locationService
            )
            
        case .chat:
            let viewModel = container.makeChatViewModel()
            return ChatViewController(viewModel: viewModel)
            
        case .profile:
            let viewModel = container.makeProfileViewModel()
            let view = ProfileView(viewModel: viewModel)
                .environment(\.navigate) { [weak self] destination in
                    self?.handle(destination)
                }
            return hostingController(view)
        }
    }
    
    private func showPetDetails(pet: Pet) {
        guard let navigation = currentTabNavigation() else { return }
        
        let viewModel = container.makePetDetailsViewModel(pet: pet)
        let view = PetDetailsView(viewModel: viewModel)
            .environment(\.navigate) { [weak self] destination in
                self?.handle(destination)
            }
        
        navigation.pushViewController(
            hostingController(view, hidesBottomBarWhenPushed: true),
            animated: true
        )
    }
    
    private func showAddPet(householdId: String) {
        guard let navigation = currentTabNavigation() else { return }
        
        let viewModel = container.makeAddPetViewModel(householdId: householdId)
        let view = AddPetView(viewModel: viewModel)
        
        navigation.pushViewController(
            hostingController(view, hidesBottomBarWhenPushed: true),
            animated: true
        )
    }
    
    private func showEditPet(pet: Pet, onSave: @escaping (Pet) -> Void) {
        guard let navigation = currentTabNavigation() else { return }
        
        let viewModel = container.makeEditPetViewModel(pet: pet)
        let view = EditPetView(viewModel: viewModel, onSave: onSave)
        
        let viewController = hostingController(view)
        viewController.modalPresentationStyle = .pageSheet
        navigation.present(viewController, animated: true)
    }
    
    private func showAddHealthLog(
        petId: String,
        category: LogCategory,
        onSave: @escaping () -> Void
    ) {
        guard let navigation = currentTabNavigation() else { return }
        
        let viewModel = container.makeAddHealthLogViewModel(
            petId: petId,
            category: category
        )
        viewModel.onSaveSuccess = { [weak navigation] in
            navigation?.dismiss(animated: true)
            onSave()
        }
        
        let view = AddHealthLogView(viewModel: viewModel)
        navigation.present(hostingController(view), animated: true)
    }
    
    private func showLogDetails(petId: String, petName: String, log: HealthLog)
    {
        guard let navigation = currentTabNavigation() else { return }
        
        let viewModel = container.makeLogDetailsViewModel(
            petId: petId,
            petName: petName,
            log: log
        )
        let view = LogDetailsView(viewModel: viewModel)
        
        navigation.pushViewController(
            hostingController(view, hidesBottomBarWhenPushed: true),
            animated: true
        )
    }
    
    private func showRemindersList(items: [ReminderItem]) {
        guard let navigation = currentTabNavigation() else { return }
        
        let viewModel = RemindersViewModel(reminders: items)
        let view = RemindersView(viewModel: viewModel)
            .environment(\.navigate) { [weak self] destination in
                self?.handle(destination)
            }
        
        navigation.pushViewController(
            hostingController(view, hidesBottomBarWhenPushed: true),
            animated: true
        )
    }
}

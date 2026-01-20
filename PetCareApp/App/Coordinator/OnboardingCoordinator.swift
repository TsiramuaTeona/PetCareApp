//
//  OnboardingCoordinator.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 20.01.26.
//

import Foundation
import UIKit

// MARK: - Onboarding State

enum OnboardingState {
    private static let key = "hasSeenOnboarding"

    static var hasSeen: Bool {
        get { UserDefaults.standard.bool(forKey: key) }
        set { UserDefaults.standard.set(newValue, forKey: key) }
    }
}

// MARK: - Onboarding Coordinator

final class OnboardingCoordinator: Coordinator {

    // MARK: - Properties
    
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []

    private let onFinish: () -> Void

    // MARK: - Initializer
    
    init(
        navigationController: UINavigationController,
        onFinish: @escaping () -> Void
    ) {
        self.navigationController = navigationController
        self.onFinish = onFinish
    }

    // MARK: - Methods
    
    func start() {
        let viewController = OnboardingViewController()
        viewController.onFinish = { [weak self] in
            guard let self else { return }
            OnboardingState.hasSeen = true
            self.onFinish()
        }

        navigationController.setNavigationBarHidden(true, animated: false)
        navigationController.setViewControllers([viewController], animated: false)
    }

    func stop() {
        navigationController.setViewControllers([], animated: false)
    }
}

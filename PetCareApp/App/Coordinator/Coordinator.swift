//
//  Coordinator.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 03.01.26.
//


import UIKit

protocol Coordinator: AnyObject {
    // MARK: - Properties
    
    var navigationController: UINavigationController { get set }
    var childCoordinators: [Coordinator] { get set }
    
    // MARK: - Methods
    
    func start()
    func childDidFinish(_ child: Coordinator?)
}

// MARK: - Extension
extension Coordinator {
    func childDidFinish(_ child: Coordinator?) {
        for (index, coordinator) in childCoordinators.enumerated() {
            if coordinator === child {
                childCoordinators.remove(at: index)
                break
            }
        }
    }
}

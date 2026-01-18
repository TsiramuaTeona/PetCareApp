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
    func stop()
    func childDidFinish(_ child: Coordinator?)
}

// MARK: - Extension

extension Coordinator {
    func stop() {}
    
    func childDidFinish(_ child: Coordinator?) {
        guard let child else { return }
        
        child.stop()
        
        childCoordinators.removeAll { $0 === child }
    }
}

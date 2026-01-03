//
//  MapViewController.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 03.01.26.
//


import UIKit

final class MapViewController: UIViewController {
    // MARK: - Properties
    
    private let mapView = UIView() // Placeholder for actual map view
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    
    // MARK: - Setup
    
    func setupView() {
        view.backgroundColor = .white
        mapView.backgroundColor = .lightGray // Placeholder color
        mapView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mapView)
        
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
    }
}

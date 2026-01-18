//
//  VetClusterView.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 06.01.26.
//

import MapKit

final class VetClusterView: MKMarkerAnnotationView {
    // MARK: - Properties
    
    static let reuseID = "VetClusterView"

    // MARK: - Initializers
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Methods
    
    private func configure() {
        markerTintColor = .brandSecondary
        glyphText = "🐾"
        canShowCallout = false
    }
}

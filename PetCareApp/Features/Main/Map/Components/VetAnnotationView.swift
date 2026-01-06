//
//  VetAnnotationView.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 06.01.26.
//


import MapKit

final class VetAnnotationView: MKMarkerAnnotationView {
    // MARK: - Properties
    
    static let reuseID = "VetAnnotationView"

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
        canShowCallout = true
        glyphImage = UIImage(systemName: "pet.carrier.fill")
        markerTintColor = .brandSecondary
        clusteringIdentifier = "vet"
        rightCalloutAccessoryView = UIButton(type: .detailDisclosure)

        let statusLabel = UILabel()
        statusLabel.font = .systemFont(ofSize: 15)
        statusLabel.textColor = .textSecondary
        statusLabel.text = "Vet Clinic"

        leftCalloutAccessoryView = statusLabel
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        guard animated else { return }

        if selected {
            UIView.animate(withDuration: 0.2) {
                self.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
            }
        } else {
            UIView.animate(withDuration: 0.2) {
                self.transform = .identity
            }
        }
    }
}

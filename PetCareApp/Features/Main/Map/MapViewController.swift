//
//  MapViewController.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 03.01.26.
//

import MapKit
import UIKit

final class MapViewController: UIViewController {
    // MARK: - Properties
    
    private let viewModel: MapViewModel
    private var locationService: LocationServiceProtocol
    
    private let mapView: MKMapView = {
        let map = MKMapView()
        map.mapType = .satelliteFlyover
        map.showsCompass = true
        map.showsScale = true
        map.showsUserLocation = true
        map.userTrackingMode = .follow
        map.translatesAutoresizingMaskIntoConstraints = false
        return map
    }()
    
    // MARK: - Initializer
    
    init(
        viewModel: MapViewModel,
        locationService: LocationServiceProtocol
    ) {
        self.viewModel = viewModel
        self.locationService = locationService
        super.init(nibName: nil, bundle: nil)
        
        title = "Vets Nearby"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .mainBackground
        
        setupMap()
        setupBindings()
        
        locationService.delegate = self
        locationService.requestPermission()
    }
    
    // MARK: - Methods
    
    func setupMap() {
        mapView.delegate = self
        view.addSubview(mapView)
        
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        let trackingButton = MKUserTrackingButton(mapView: mapView)
        trackingButton.backgroundColor = .mainBackground.withAlphaComponent(0.7)
        trackingButton.layer.cornerRadius = 10
        trackingButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(trackingButton)
        
        NSLayoutConstraint.activate([
            trackingButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
            trackingButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24)
        ])
        
        mapView.register(
            VetAnnotationView.self,
            forAnnotationViewWithReuseIdentifier: VetAnnotationView.reuseID
        )
        
        mapView.register(
            VetClusterView.self,
            forAnnotationViewWithReuseIdentifier: VetClusterView.reuseID
        )
    }
    
    private func setupBindings() {
        viewModel.onAnnotationsUpdated = { [weak self] annotations in
            guard let self else { return }
            DispatchQueue.main.async {
                let nonUser = self.mapView.annotations.filter { !($0 is MKUserLocation) }
                self.mapView.removeAnnotations(nonUser)
                self.mapView.addAnnotations(annotations)
            }
        }
        
        viewModel.onLoadingStateChanged = { [weak self] isLoading in
            guard let self else { return }
            if isLoading {
                let spinner = UIActivityIndicatorView(style: .medium)
                spinner.startAnimating()
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: spinner)
            } else {
                self.navigationItem.rightBarButtonItem = nil
            }
        }
    }
    
    private func openDirections(to mapItem: MKMapItem) {
        MKMapItem.openMaps(
            with: [mapItem],
            launchOptions: [
                MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
            ]
        )
    }
}

// MARK: - LocationServiceDelegate

extension MapViewController: LocationServiceDelegate {
    
    // MARK: - Methods
    
    func didUpdateLocation(_ location: CLLocation) {
        Task {
            await viewModel.load(around: location)
        }
    }
    
    func didFailWithError(_ error: Error) {
        print("Location Error: \(error.localizedDescription)")
    }
}

// MARK: - MKMapViewDelegate

extension MapViewController: MKMapViewDelegate {
    
    // MARK: - Methods
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            return nil
        }
        
        if let cluster = annotation as? MKClusterAnnotation {
            return mapView.dequeueReusableAnnotationView(
                withIdentifier: VetClusterView.reuseID,
                for: cluster
            )
        }
        
        if let vet = annotation as? VetAnnotation {
            return mapView.dequeueReusableAnnotationView(
                withIdentifier: VetAnnotationView.reuseID,
                for: vet
            )
        }
        
        return nil
    }
    
    func mapView(
        _ mapView: MKMapView,
        annotationView view: MKAnnotationView,
        calloutAccessoryControlTapped control: UIControl
    ) {
        guard let vet = view.annotation as? VetAnnotation else { return }
        let sheetViewController = VetActionSheetViewController(vet: vet)
        sheetViewController.modalPresentationStyle = .pageSheet
        present(sheetViewController, animated: true)
        
    }
}

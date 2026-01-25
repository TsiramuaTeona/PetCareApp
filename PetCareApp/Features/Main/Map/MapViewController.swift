//
//  MapViewController.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 03.01.26.
//

import MapKit
import UIKit
import os

final class MapViewController: UIViewController {
    // MARK: - Properties
    
    private let viewModel: MapViewModel
    private var locationService: LocationServiceProtocol
    
    private var hideMessageWorkItem: DispatchWorkItem?
    
    private let mapView: MKMapView = {
        let map = MKMapView()
        map.mapType = .satelliteFlyover
        map.showsCompass = true
        map.showsScale = true
        map.showsUserLocation = false
        map.userTrackingMode = .none
        map.translatesAutoresizingMaskIntoConstraints = false
        return map
    }()
    
    private let messageContainer: UIStackView = {
        let stack = UIStackView()
        stack.backgroundColor = .mainBackground.withAlphaComponent(0.7)
        stack.axis = .vertical
        stack.spacing = 10
        stack.alignment = .center
        stack.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layer.cornerRadius = 10
        stack.layer.masksToBounds = true
        stack.alpha = 0
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = .textSecondary
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let settingsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Settings", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 13, weight: .semibold)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
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
        setupMessage()
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
    
    private func setupMessage() {
        view.addSubview(messageContainer)
        messageContainer.addArrangedSubview(messageLabel)
        messageContainer.addArrangedSubview(settingsButton)
        
        setupOpenSettingsAction()
        
        NSLayoutConstraint.activate([
            messageContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            messageContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            messageContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24)
        ])
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
    
    private func showMessage(_ text: String, autoHideAfter seconds: TimeInterval? = 4) {
        hideMessageWorkItem?.cancel()
        messageLabel.text = text
        
        UIView.animate(withDuration: 0.2) {
            self.messageContainer.alpha = 1
        }
        
        if let seconds {
            let work = DispatchWorkItem { [weak self] in
                self?.hideMessage()
            }
            hideMessageWorkItem = work
            DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: work)
        }
    }
    
    private func hideMessage() {
        UIView.animate(withDuration: 0.2) {
            self.messageContainer.alpha = 0
        }
    }
    
    private func setupOpenSettingsAction() {
        settingsButton.addAction(UIAction { _ in
            guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
            UIApplication.shared.open(url)
        }, for: .touchUpInside)
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
            
            if mapView.showsUserLocation == false {
                mapView.showsUserLocation = true
                mapView.userTrackingMode = .follow
            }
            
            hideMessage()
            
            Task {
                await viewModel.load(around: location)
            }
        }
        
    func didFailWithError(_ error: Error) {
        AppLogger.location.error("Location error: \(error.localizedDescription, privacy: .public)")
        
        mapView.showsUserLocation = false
        mapView.userTrackingMode = .none
        
        showMessage(
            "Turn on Location in Settings → Privacy → Location Services → PetCare → While Using the App.",
            autoHideAfter: nil
        )
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
    
    func mapView(_ mapView: MKMapView, didFailToLocateUserWithError error: Error) {
        AppLogger.location.error("Map failed to locate user: \(error.localizedDescription, privacy: .public)")
    }
}

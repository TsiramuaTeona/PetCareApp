//
//  LocationService.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 06.01.26.
//

import CoreLocation

// MARK: - LocationServiceDelegate

protocol LocationServiceDelegate: AnyObject {
    func didUpdateLocation(_ location: CLLocation)
    func didFailWithError(_ error: Error)
}

// MARK: - LocationServiceProtocol

protocol LocationServiceProtocol {
    var delegate: LocationServiceDelegate? { get set }
    func requestPermission()
}

// MARK: - LocationService

final class LocationService: NSObject, LocationServiceProtocol {
    
    // MARK: - Properties
    
    weak var delegate: LocationServiceDelegate?
    private let manager = CLLocationManager()
    
    // MARK: - Initializer
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }
    
    // MARK: - Methods
    
    func requestPermission() {
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        
        if let location = manager.location {
            delegate?.didUpdateLocation(location)
        }
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationService: CLLocationManagerDelegate {
    
    // MARK: - Methods
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse
            || manager.authorizationStatus == .authorizedAlways
        {
            manager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        delegate?.didUpdateLocation(location)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        delegate?.didFailWithError(error)
    }
}

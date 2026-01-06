//
//  MapViewModel.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 03.01.26.
//


import MapKit

@MainActor
final class MapViewModel {
    
    // MARK: - Properties
    
    var onAnnotationsUpdated: (([VetAnnotation]) -> Void)?
    var onLoadingStateChanged: ((Bool) -> Void)?
    
    private(set) var annotations: [VetAnnotation] = [] {
        didSet {
            onAnnotationsUpdated?(annotations)
        }
    }
    
    private var isLoading: Bool = false {
        didSet {
            onLoadingStateChanged?(isLoading)
        }
    }
    
    private let mapService: MapServiceProtocol
    private var lastCenter: CLLocationCoordinate2D?
    
    // MARK: - Initializer
    
    init(mapService: MapServiceProtocol) {
        self.mapService = mapService
    }
    
    // MARK: - Methods
    
    func load(around location: CLLocation) async {
        guard shouldReload(for: location.coordinate) else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        let region = MKCoordinateRegion(
            center: location.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
        
        do {
            let newAnnotations = try await mapService.search(region: region)
            self.annotations = newAnnotations
            lastCenter = location.coordinate
        } catch {
            print("Search failed: \(error.localizedDescription)")
        }
    }
    
    private func shouldReload(for coordinate: CLLocationCoordinate2D) -> Bool {
        guard let last = lastCenter else { return true }
        let lastLoc = CLLocation(latitude: last.latitude, longitude: last.longitude)
        let newLoc = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        return lastLoc.distance(from: newLoc) > 500
    }
}

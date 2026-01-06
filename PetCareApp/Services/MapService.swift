//
//  MapService.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 06.01.26.
//


import MapKit

// MARK: - MapServiceProtocol

protocol MapServiceProtocol {
    func search(region: MKCoordinateRegion) async throws -> [VetAnnotation]
}

// MARK: - MapService

final class MapService: MapServiceProtocol {
    
    // MARK: - Method
    
    func search(region: MKCoordinateRegion) async throws -> [VetAnnotation] {
        
        let request = MKLocalSearch.Request()
        request.region = region
        request.naturalLanguageQuery = "Veterinarian"
        request.resultTypes = .pointOfInterest
        
        let response = try await MKLocalSearch(request: request).start()
        
        return response.mapItems.map(VetAnnotation.init)
    }
}

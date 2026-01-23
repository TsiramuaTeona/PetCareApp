//
//  MapServiceMock.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 23.01.26.
//

import MapKit
@testable import PetCareApp

final class MapServiceMock: MapServiceProtocol {
    
    // MARK: - Properties
    
    private(set) var searchCalls: [MKCoordinateRegion] = []
    
    var resultToReturn: [VetAnnotation] = []
    var errorToThrow: Error?
    
    var shouldBlock = false
    private var continuation: CheckedContinuation<Void, Never>?
    
    // MARK: - Methods
    
    func search(region: MKCoordinateRegion) async throws -> [VetAnnotation] {
        searchCalls.append(region)
        
        if shouldBlock {
            await withCheckedContinuation { cont in
                continuation = cont
            }
        }
        
        if let errorToThrow { throw errorToThrow }
        return resultToReturn
    }
    
    func resumeSearch() {
        continuation?.resume()
        continuation = nil
    }
}

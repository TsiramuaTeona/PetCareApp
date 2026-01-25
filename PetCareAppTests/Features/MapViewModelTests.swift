//
//  MapViewModelTests.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 23.01.26.
//

import Testing
import MapKit
import CoreLocation

@testable import PetCareApp


@Suite("MapViewModel")
@MainActor
struct MapViewModelTests {
    
    @Test("load first time -> toggles loading, calls service, updates annotations")
    func load_firstTime_success() async {
        let service = MapServiceMock()
        service.resultToReturn = [
            makeAnnotation(id: "1", lat: 41.715, lon: 44.783)
        ]
        
        let sut = MapViewModel(mapService: service)
        
        var loadingEvents: [Bool] = []
        sut.onLoadingStateChanged = { loadingEvents.append($0) }
        
        var annotationEvents: [[VetAnnotation]] = []
        sut.onAnnotationsUpdated = { annotationEvents.append($0) }
        
        await sut.load(around: makeLocation(41.715, 44.783))
        
        #expect(service.searchCalls.count == 1)
        #expect(loadingEvents == [true, false])
        
        #expect(annotationEvents.count == 1)
        #expect(annotationEvents[0].count == 1)
        
        #expect(sut.annotations.count == 1)
        #expect(sut.annotations[0].title == "Vet 1")
    }
    
    @Test("load second time within 500m -> does not reload (no service call)")
    func load_within500m_doesNotReload() async {
        let service = MapServiceMock()
        service.resultToReturn = [
            makeAnnotation(id: "1", lat: 41.715, lon: 44.783)
        ]
        
        let sut = MapViewModel(mapService: service)
        
        await sut.load(around: makeLocation(41.715, 44.783))
        await sut.load(around: makeLocation(41.7155, 44.783))
        
        #expect(service.searchCalls.count == 1)
    }
    
    @Test("load after >500m -> reloads (service called twice, annotations replaced)")
    func load_over500m_reloads() async {
        let service = MapServiceMock()
        service.resultToReturn = [
            makeAnnotation(id: "1", lat: 41.715, lon: 44.783)
        ]
        
        let sut = MapViewModel(mapService: service)
        
        await sut.load(around: makeLocation(41.715, 44.783))
        
        service.resultToReturn = [
            makeAnnotation(id: "2", lat: 41.715, lon: 44.783)
        ]
        
        await sut.load(around: makeLocation(41.725, 44.783))
        
        #expect(service.searchCalls.count == 2)
        #expect(sut.annotations.count == 1)
        #expect(sut.annotations[0].title == "Vet 2")
    }
    
    @Test("if already loading -> second call is ignored")
    func load_whileLoading_ignored() async {
        let service = MapServiceMock()
        service.resultToReturn = [
            makeAnnotation(id: "1", lat: 41.715, lon: 44.783)
        ]
        service.shouldBlock = true
        
        let sut = MapViewModel(mapService: service)
        
        var loadingEvents: [Bool] = []
        sut.onLoadingStateChanged = { loadingEvents.append($0) }
        
        let task1 = Task { await sut.load(around: makeLocation(41.715, 44.783)) }
        
        await Task.yield()
        
        await sut.load(around: makeLocation(41.725, 44.783))
        
        service.resumeSearch()
        _ = await task1.value
        
        #expect(service.searchCalls.count == 1)
        #expect(loadingEvents.first == true)
        #expect(loadingEvents.last == false)
    }
    
    @Test("service throws -> loading toggles back, annotations not changed")
    func load_error_doesNotUpdateAnnotations() async {
        let service = MapServiceMock()
        service.errorToThrow = TestError.message("fail")
        
        let sut = MapViewModel(mapService: service)
        
        var annotationEvents: [[VetAnnotation]] = []
        sut.onAnnotationsUpdated = { annotationEvents.append($0) }
        
        var loadingEvents: [Bool] = []
        sut.onLoadingStateChanged = { loadingEvents.append($0) }
        
        await sut.load(around: makeLocation(41.715, 44.783))
        
        #expect(service.searchCalls.count == 1)
        #expect(loadingEvents == [true, false])
        
        #expect(sut.annotations.isEmpty)
        #expect(annotationEvents.isEmpty)
    }
}

// MARK: - Helpers

private func makeLocation(_ lat: CLLocationDegrees, _ lon: CLLocationDegrees) -> CLLocation {
    CLLocation(latitude: lat, longitude: lon)
}

private func makeAnnotation(id: String, lat: Double, lon: Double) -> VetAnnotation {
    let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
    let placemark = MKPlacemark(coordinate: coordinate)
    let item = MKMapItem(placemark: placemark)
    item.name = "Vet \(id)"
    return VetAnnotation(mapItem: item)
}

//
//  VetAnnotation.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 06.01.26.
//


import MapKit

final class VetAnnotation: NSObject, MKAnnotation {
    
    let coordinate: CLLocationCoordinate2D
    let title: String?
    let subtitle: String?
    
    let phoneNumber: String?
    let website: URL?
    let mapItem: MKMapItem
    
    init(mapItem: MKMapItem) {
        self.mapItem = mapItem
        self.coordinate = mapItem.placemark.coordinate
        self.title = mapItem.name
        self.subtitle = mapItem.placemark.title
        self.phoneNumber = mapItem.phoneNumber
        self.website = mapItem.url
    }
}
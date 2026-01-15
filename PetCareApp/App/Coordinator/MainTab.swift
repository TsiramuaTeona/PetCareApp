//
//  MainTab.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 03.01.26.
//


import UIKit

enum MainTab: Int, CaseIterable {
    case home
    case map
    case shop
    case profile
    
    var title: String {
        switch self {
        case .home: return "Home"
        case .map: return "Vets"
        case .shop: return "Shop"
        case .profile: return "Profile"
        }
    }
    
    var icon: UIImage? {
        switch self {
        case .home: return UIImage(systemName: "house")
        case .map: return UIImage(systemName: "map")
        case .shop: return UIImage(systemName: "cart")
        case .profile: return UIImage(systemName: "person.circle")
        }
    }
}

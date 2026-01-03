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

    var title: String {
        switch self {
        case .home:
            return "Home"
        case .map:
            return "Vets"
        case .shop:
            return "Shop"
        }
    }

    var icon: UIImage? {
        switch self {
        case .home:
            return UIImage(systemName: "house")
        case .map:
            return UIImage(systemName: "map")
        case .shop:
            return UIImage(systemName: "cart")
        }
    }
}

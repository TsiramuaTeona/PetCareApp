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
    case chat
    case profile
    
    var title: String {
        switch self {
        case .home: return "Home"
        case .map: return "Vets"
        case .chat: return "Chat"
        case .profile: return "Profile"
        }
    }
    
    var icon: UIImage? {
        switch self {
        case .home: return UIImage(systemName: "house")
        case .map: return UIImage(systemName: "map")
        case .chat: return UIImage(systemName: "message")
        case .profile: return UIImage(systemName: "person.circle")
        }
    }
}

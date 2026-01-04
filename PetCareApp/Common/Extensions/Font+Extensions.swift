//
//  Font+Extensions.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 04.01.26.
//

import SwiftUI

extension Font {
    // Large Titles - Use Rounded design for friendliness
    static let appDisplay = Font.system(size: 34, weight: .heavy, design: .rounded)
    
    // Headers - Rounded and soft
    static let appHeader = Font.system(size: 22, weight: .bold, design: .rounded)
    
    // Body text - Keep default for readability, or use rounded for a very casual look
    static let appTitle = Font.system(size: 16, weight: .semibold, design: .rounded)
    static let appBody = Font.system(size: 16, weight: .regular, design: .default)
    
    // Button text
    static let appButton = Font.system(size: 17, weight: .bold, design: .rounded)
    
    static let appCaption = Font.system(size: 13, weight: .regular, design: .default)
}

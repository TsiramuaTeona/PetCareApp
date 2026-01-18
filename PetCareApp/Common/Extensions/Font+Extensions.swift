//
//  Font+Extensions.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 04.01.26.
//

import SwiftUI

extension Font {
    static let appDisplay = Font.system(
        size: 34,
        weight: .heavy,
        design: .rounded
    )
    
    static let appHeader = Font.system(
        size: 22,
        weight: .bold,
        design: .rounded
    )
    
    static let appButton = Font.system(
        size: 17,
        weight: .bold,
        design: .rounded
    )
    
    static let appTitle = Font.system(
        size: 16,
        weight: .semibold,
        design: .rounded
    )
    
    static let appBody = Font.system(
        size: 15,
        weight: .regular,
        design: .default
    )
    
    static let appCaption = Font.system(
        size: 13,
        weight: .regular,
        design: .default
    )
}

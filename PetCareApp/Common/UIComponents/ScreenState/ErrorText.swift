//
//  ErrorText.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 03.01.26.
//


import SwiftUI

struct ErrorText: View {
    // MARK: - Properties
    
    let error: String?
    let visible: Bool
    
    // MARK: - Body
    
    var body: some View {
        Text(error ?? " ")
            .font(.appCaption)
            .foregroundColor(.error)
            .opacity(!visible ? 0 : 1)
            .accessibilityHidden(!visible)
            .animation(.easeInOut, value: error)
    }
}

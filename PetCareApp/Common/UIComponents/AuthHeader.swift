//
//  AuthHeader.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 04.01.26.
//


import SwiftUI

struct AuthHeader: View {
    // MARK: - Properties
    
    let title: String
    var subtitle: String? = nil
    
    // MARK: - Body
    
    var body: some View {
        content
    }
    
    // MARK: - Subviews
    
    @ViewBuilder
    private var content: some View {
        Text(title)
            .font(.appDisplay)
            .foregroundStyle(.brandPrimary)
        
        if let subtitle {
            Text(subtitle)
                .font(.appBody)
                .foregroundStyle(.textSecondary)
                .multilineTextAlignment(.center)
        }
        
        Image("AppLogo")
            .resizable()
            .scaledToFit()
            .frame(width: 100, height: 100)
    }
}

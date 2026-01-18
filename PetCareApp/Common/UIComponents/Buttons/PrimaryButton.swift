//
//  PrimaryButton.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 04.01.26.
//


import SwiftUI

// MARK: - PrimaryButton Style

struct PrimaryButton: ButtonStyle {
    // MARK: - Properties
    
    let isLoading: Bool
    
    // MARK: - Body
    
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            if isLoading {
                ProgressView()
                    .tint(.white)
            }
            
            configuration.label
            
        }
        .font(.appButton)
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            isLoading
            ? .brandPrimary.opacity(0.6)
            : (configuration.isPressed
               ? .brandPrimary.opacity(0.8)
               : .brandPrimary)
        )
        .foregroundColor(.white)
        .cornerRadius(10)
        .scaleEffect(configuration.isPressed && !isLoading ? 0.98 : 1)
        .opacity(isLoading ? 0.9 : 1)
        .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - ButtonStyle Extension

extension ButtonStyle where Self == PrimaryButton {
    static func primary(isLoading: Bool) -> PrimaryButton {
        PrimaryButton(isLoading: isLoading)
    }
}

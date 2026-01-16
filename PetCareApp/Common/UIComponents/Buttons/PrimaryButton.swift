//
//  PrimaryButton.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 04.01.26.
//


import SwiftUI

struct PrimaryButton: View {
    // MARK: - Properties
    
    let title: String
    let isLoading: Bool
    let action: () -> Void
    
    // MARK: - Body
    
    var body: some View {
        content
            .font(.appButton)
            .frame(maxWidth: .infinity)
            .padding()
            .background(.brandPrimary)
            .foregroundColor(.white)
            .cornerRadius(10)
            .disabled(isLoading)
    }
    
    // MARK: - Subviews
    
    private var content: some View {
        Button(action: action) {
            if isLoading {
                ProgressView()
                    .tint(.white)
            } else {
                Text(title)
            }
        }
    }
}

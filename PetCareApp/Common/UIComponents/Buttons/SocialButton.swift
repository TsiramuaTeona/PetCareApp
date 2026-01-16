//
//  SocialButton.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 04.01.26.
//


import SwiftUI

struct SocialButton: View {
    // MARK: - Properties
    
    let title: String
    let iconName: String
    let isLoading: Bool
    let action: () -> Void
    
    // MARK: - Body
    
    var body: some View {
        Button(action: action) {
            if isLoading {
                ProgressView()
                    .tint(.textPrimary)
            } else {
               
                HStack {
                    Image(iconName)
                    Text(title)
                }
            }
        }
        .font(.appBody)
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .foregroundColor(.textPrimary)
        .cornerRadius(10)
        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
        .disabled(isLoading)
    }
}

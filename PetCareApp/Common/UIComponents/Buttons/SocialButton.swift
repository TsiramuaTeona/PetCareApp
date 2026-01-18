//
//  SocialButton.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 04.01.26.
//

import SwiftUI

// MARK: - SocialButton Style

struct SocialButton: ButtonStyle {
    // MARK: - Properties

    let isLoading: Bool

    // MARK: - Body

    func makeBody(configuration: Configuration) -> some View {
        HStack {
            if isLoading {
                ProgressView()
                    .tint(.textPrimary)
            }

            configuration.label
                .opacity(isLoading ? 0.6 : 1)

        }
        .font(.appButton)
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            configuration.isPressed
                ? Color(.systemGray6).opacity(0.8)
                : Color(.systemGray6)
        )
        .foregroundColor(.textPrimary)
        .cornerRadius(10)
        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
        .scaleEffect(configuration.isPressed && !isLoading ? 0.98 : 1)
        .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - ButtonStyle Extension

extension ButtonStyle where Self == SocialButton {
    static func social(isLoading: Bool) -> SocialButton {
        SocialButton(isLoading: isLoading)
    }
}

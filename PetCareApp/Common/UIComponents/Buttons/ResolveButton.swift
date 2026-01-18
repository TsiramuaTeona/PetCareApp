//
//  ResolveButton.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 13.01.26.
//

import SwiftUI

// MARK: - ResolveButton Style

struct ResolveButton: ButtonStyle {

    // MARK: - Properties

    let categoryColor: Color

    // MARK: - Body

    func makeBody(configuration: Configuration) -> some View {
        Image(systemName: "checkmark.arrow.trianglehead.counterclockwise")
            .font(.system(size: 28))
            .foregroundColor(
                configuration.role == .destructive ? .error : categoryColor
            )
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .opacity(configuration.isPressed ? 0.7 : 1.0)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)

    }
}

// MARK: - ButtonStyle Extension

extension ButtonStyle where Self == ResolveButton {
    static func resolve(categoryColor: Color) -> ResolveButton {
        ResolveButton(categoryColor: categoryColor)
    }
}

//
//  QuickAddCard.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 20.01.26.
//

import SwiftUI

struct QuickAddCard: View {
    // MARK: - Properties

    let category: LogCategory
    var onTap: () -> Void

    // MARK: - Body

    var body: some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .shadowCard()
            .onTapGesture {
                onTap()
            }
    }

    // MARK: - Subviews
    
    private var content: some View {
        VStack(spacing: 10) {
            Image(systemName: category.icon)
                .foregroundColor(category.color)
                .font(.appTitle)
                .padding(10)
                .background(category.color.opacity(0.1))
                .clipShape(Circle())

            Text(category.rawValue)
                .font(.appButton)
                .foregroundColor(category.color)
        }
    }
}

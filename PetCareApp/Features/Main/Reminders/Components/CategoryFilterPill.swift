//
//  CategoryFilterPill.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 13.01.26.
//

import SwiftUI

struct CategoryFilterPill: View {
    // MARK: - Properties
    
    let title: String
    let icon: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    // MARK: - Body
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: isSelected ? "checkmark" : icon)
                    .font(.caption.weight(.bold))
                
                Text(title)
                    .font(.appButton)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(isSelected ? color.opacity(0.15) : Color.surface)
            )
            .overlay(
                Capsule()
                    .stroke(
                        isSelected ? color : Color.textSecondary.opacity(0.2),
                        lineWidth: 1
                    )
            )
            .foregroundColor(isSelected ? color : .textSecondary)
        }
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3), value: isSelected)
    }
}

//
//  ThemeOptionCard.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 18.01.26.
//

import SwiftUI

struct ThemeOptionCard: View {
    // MARK: - Properties
    
    let theme: AppTheme
    let selected: AppTheme
    let action: () -> Void
    
    private var isSelected: Bool { selected == theme }
    
    // MARK: - Body
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Image(systemName: theme.iconName)
                    .font(.title3)
                
                Text(theme.title)
                    .font(.appTitle)
            }
            .foregroundColor(isSelected ? .brandPrimary : .textSecondary)
            .padding()
            .frame(maxWidth: .infinity)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(
                        isSelected
                        ? Color.brandPrimary
                        : Color.brandSecondary.opacity(0.25),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
        }
        .buttonStyle(.plain)
        .animation(.snappy, value: isSelected)
    }
}

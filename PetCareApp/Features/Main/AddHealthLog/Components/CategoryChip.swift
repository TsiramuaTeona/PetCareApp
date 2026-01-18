//
//  CategoryChip.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 12.01.26.
//

import SwiftUI

struct CategoryChip: View {
    // MARK: - Properties
    
    let category: LogCategory
    let isSelected: Bool
    let onTap: () -> Void
    
    // MARK: - Body
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                Image(systemName: category.icon)
                    .font(.system(size: 20))
                
                Text(category.rawValue)
                    .font(.appCaption)
                    .fontWeight(.medium)
            }
            .foregroundColor(isSelected ? .white : .textSecondary)
            .frame(width: 80, height: 80)
            .background(isSelected ? category.color : .surface)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(
                        isSelected
                        ? Color.clear : Color.textSecondary.opacity(0.1),
                        lineWidth: 1
                    )
            )
            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
    }
}

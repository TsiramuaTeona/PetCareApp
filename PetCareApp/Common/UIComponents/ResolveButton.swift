//
//  ResolveButton.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 13.01.26.
//


import SwiftUI

struct ResolveButton: View {
    // MARK: - Properties
    
    let action: () -> Void
    let isUrgent: Bool
    let categoryColor: Color
    
    // MARK: - Body
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "checkmark.circle.dotted")
                .font(.system(size: 28))
                .foregroundColor(isUrgent ? .error : categoryColor)
        }
        .buttonStyle(.plain)
    }
}

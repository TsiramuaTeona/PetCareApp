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
        content
            .buttonStyle(.plain)
    }
    
    // MARK: - Subviews
    
    private var content: some View {
        Button(action: action) {
            Image(systemName: "checkmark.arrow.trianglehead.counterclockwise")
                .font(.system(size: 28))
                .foregroundColor(isUrgent ? .error : categoryColor)
        }
    }
}

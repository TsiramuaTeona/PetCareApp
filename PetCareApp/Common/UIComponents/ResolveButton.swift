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
            HStack(spacing: 6) {
                Image(systemName: "checkmark")
                    .font(.caption.bold())
                
                Text("Done")
                    .font(.appCaption.bold())
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(isUrgent ? .error : categoryColor)
            )
            .foregroundColor(.white)
        }
        .buttonStyle(.plain)
    }
}

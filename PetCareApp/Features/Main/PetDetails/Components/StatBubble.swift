//
//  StatBubble.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 09.01.26.
//


import SwiftUI

struct StatBubble: View {
    // MARK: - Properties
    
    let label: String
    let value: String
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 6) {
            Text(label)
                .font(.appCaption)
                .foregroundColor(.textSecondary)
            
            Text(value)
                .font(.appTitle)
                .foregroundColor(.brandSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.brandSecondary.opacity(0.2))
        .cornerRadius(10)
    }
}

//
//  ErrorView.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 03.01.26.
//


import SwiftUI

struct ErrorView: View {
    // MARK: - Properties
    
    let message: String?
    
    // MARK: - Body
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
            Text(message ?? " ")
                .font(.appBody)
                .multilineTextAlignment(.leading)
            
            Spacer()
        }
        .foregroundStyle(.error)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.error.opacity(0.08))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.error.opacity(0.35), lineWidth: 1)
        )
        .opacity(message == nil ? 0 : 1)
        .accessibilityHidden(message == nil)
        .animation(.easeInOut, value: message)
    }
}

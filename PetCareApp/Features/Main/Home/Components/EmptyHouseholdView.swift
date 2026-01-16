//
//  EmptyHouseholdView.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 06.01.26.
//


import SwiftUI

struct EmptyHouseholdView: View {
    // MARK: - Properties
    
    let userName: String
    let action: () -> Void
    
    // MARK: - Body
    
    var body: some View {
        content
            .padding(.horizontal, 24)
    }
    
    // MARK: - Subviews
    
    private var content: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "house.circle.fill")
                .font(.system(size: 100))
                .foregroundColor(.brandSecondary)
            
            Text("Welcome, \(userName)!")
                .font(.appDisplay)
                .foregroundColor(.textPrimary)
                .multilineTextAlignment(.center)
            
            Text("To start tracking your pets, you need to create or join a household.")
                .font(.appBody)
                .multilineTextAlignment(.center)
                .foregroundColor(.textSecondary)
            
            PrimaryButton(
                title: "Setup Household",
                isLoading: false,
                action: action
            )
            .padding(.horizontal)
            
            Spacer()
        }
    }
}

//
//  FunFactCard.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 14.01.26.
//


import SwiftUI

struct FunFactCard: View {
    // MARK: - Properties
    
    let fact: String
    var onRefresh: () -> Void
    
    // MARK: - Body
    
    var body: some View {
        content
            .shadowCard()
    }
    
    // MARK: - Subviews
    
    private var content: some View {
        HStack(alignment: .top, spacing: 16) {
            iconSection
            factSection
            
            Spacer()
            
            Button(action: onRefresh) {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .foregroundColor(.brandPrimary.opacity(0.5))
                    .font(.caption)
            }
        }
    }
    
    private var iconSection: some View {
        ZStack {
            LinearGradient(
                colors: [.brandPink, .brandOrange],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .mask(Circle())
            .opacity(0.15)
            
            Image(systemName: "sparkles")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.brandPink, .brandOrange],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        }
        .frame(width: 48, height: 48)
    }
    
    private var factSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Did you know?")
                .font(.appCaption)
                .fontWeight(.bold)
                .textCase(.uppercase)
                .foregroundColor(.brandSecondary)
            
            Text(fact)
                .font(.appBody)
                .foregroundColor(.textPrimary)
        }
    }
}

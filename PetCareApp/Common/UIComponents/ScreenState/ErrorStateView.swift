//
//  ErrorStateView.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 03.01.26.
//


import SwiftUI

struct ErrorStateView: View {
    // MARK: - Properties
    
    let message: String
    let onRetry: () -> Void
    
    @State private var isAnimating = false
    
    // MARK: - Body
    
    var body: some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.mainBackground)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isAnimating = true
                }
            }
    }
    
    // MARK: - Subviews
    
    private var content: some View {
        VStack(spacing: 24) {
            
            imageSection
            textSection
            buttonSection
        }
    }
    
    private var imageSection: some View {
        ZStack(alignment: .bottomTrailing) {
            Image(systemName: "pawprint.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 80, height: 80)
                .foregroundStyle(.brandSecondary.opacity(0.3))
            
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.title)
                .foregroundStyle(.error)
                .background(
                    Circle()
                        .fill(.mainBackground)
                        .padding(-4)
                )
                .offset(x: 5, y: 5)
        }
        .rotationEffect(.degrees(isAnimating ? 5 : -5))
        .animation(
            .easeInOut(duration: 0.15)
            .repeatCount(4, autoreverses: true),
            value: isAnimating
        )
    }
    
    private var textSection: some View {
        VStack(spacing: 8) {
            Text("Whoops")
                .font(.appHeader)
                .foregroundStyle(.textPrimary)
            
            Text(message)
                .font(.appBody)
                .foregroundStyle(.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
    }
    
    private var buttonSection: some View {
        Button(action: onRetry) {
            Text("Try Again")
                .font(.appButton)
                .frame(minWidth: 120)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.regular)
        .padding(.top, 8)
    }
}

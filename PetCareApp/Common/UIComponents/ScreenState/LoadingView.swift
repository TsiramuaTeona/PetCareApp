//
//  LoadingView.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 03.01.26.
//


import SwiftUI

struct LoadingView: View {
    // MARK: - Properties
    
    @State private var isAnimating = false
    var pawCount: Int = 3
    var size: CGFloat = 24
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 20) {
            HStack(spacing: 15) {
                ForEach(0..<pawCount, id: \.self) { index in
                    Image(systemName: "pawprint.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: size, height: size)
                        .foregroundStyle(isAnimating ? .brandPrimary : .brandSecondary.opacity(0.6))
                        .opacity(isAnimating ? 1 : 0.3)
                        .scaleEffect(isAnimating ? 1.0 : 0.8)
                        .rotationEffect(.degrees(index % 2 == 0 ? -15 : 15))
                        .animation(
                            .easeInOut(duration: 0.6)
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.2),
                            value: isAnimating
                        )
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.mainBackground)
        .onAppear {
            isAnimating = true
        }
    }
}

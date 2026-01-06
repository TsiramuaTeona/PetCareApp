//
//  PetCard.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 06.01.26.
//


import SwiftUI

struct PetCard: View {
    // MARK: - Properties
    
    let pet: Pet
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 8) {
            if let imageUrl = pet.photoUrl, let url = URL(string: imageUrl) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    LoadingView(pawCount: 2, size: 18)
                }
                .frame(width: 100, height: 100)
                .clipShape(Circle())
                .overlay(Circle().stroke(.brandPrimary, lineWidth: 1))
            } else {
                Image(systemName: "pawprint.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .overlay(Circle().stroke(.brandPrimary, lineWidth: 1))
                    .foregroundColor(.brandSecondary)
            }
            
            Text(pet.name)
                .font(.appHeader)
                .foregroundColor(.brandPrimary)
            
            Label(pet.breed ?? "Unknown Breed", systemImage: pet.species.icon)
                .font(.appBody)
                .foregroundColor(.textSecondary)
        }
        .frame(width: 160)
        .shadowCard()
    }
}

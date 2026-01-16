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
        content
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 5)
    }
    
    // MARK: - Subviews
    
    private var content: some View {
        VStack(alignment: .leading, spacing: 0) {
            imageSection
            infoSection
        }
    }
    
    private var imageSection: some View {
        ImageView(
            urlString: pet.photoUrl,
            contentMode: .fill
        )
        .frame(width: 160, height: 120)
        .clipped()
        .overlay(alignment: .topTrailing) {
            Image(systemName: pet.species.icon)
                .font(.appCaption)
                .foregroundColor(.surface)
                .padding(6)
                .background(Color(pet.genderColor))
                .clipShape(Circle())
                .padding(8)
        }
    }
    
    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(pet.name)
                .font(.appTitle)
                .fontDesign(.rounded)
                .foregroundColor(.textPrimary)
                .lineLimit(1)
            
            Text(pet.displayBreed)
                .font(.appCaption)
                .foregroundColor(.textSecondary)
                .lineLimit(1)
            
            Text(pet.ageFormatted)
                .font(.appCaption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(.brandPrimary.opacity(0.1))
                .foregroundColor(.brandPrimary)
                .cornerRadius(4)
                .padding(.top, 4)
        }
        .padding(12)
        .frame(width: 160, alignment: .leading)
        .background(.surface)
    }
}

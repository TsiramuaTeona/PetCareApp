//
//  WeightTooltip.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 12.01.26.
//


import SwiftUI

struct WeightTooltip: View {
    // MARK: - Properties
    
    let log: HealthLog
    let onDelete: () -> Void
    let onClose: () -> Void
    
    // MARK: - Body
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(log.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.white.opacity(0.8))
                
                Text("\(log.value ?? 0, specifier: "%.1f") kg")
                    .font(.subheadline)
                    .fontWeight(.heavy)
                    .foregroundColor(.white)
            }
            
            Divider()
                .overlay(Color.white.opacity(0.2))
                .frame(height: 24)
            
            Button(action: onDelete) {
                Image(systemName: "trash.fill")
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(8)
                    .background(Color.white.opacity(0.2))
                    .clipShape(Circle())
            }
            
            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.6))
                    .padding(4)
            }
        }
        .padding(.leading, 12)
        .padding(.trailing, 8)
        .padding(.vertical, 8)
        .background(.brandSecondary)
        .cornerRadius(30)
        .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
    }
}

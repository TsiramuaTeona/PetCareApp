//
//  CalendarDateView.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 13.01.26.
//


import SwiftUI

struct CalendarDateView: View {
    // MARK: - Properties
    
    let day: String
    let month: String
    let year: String
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 0) {
            Text(day)
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 4)
                .background(.brandSecondary)
            
            Text(month)
                .font(.appTitle)
                .foregroundColor(.textPrimary)
                .padding(.top, 6)
                .frame(maxWidth: .infinity)
            
            Text(year)
                .font(.caption2)
                .fontWeight(.semibold)
                .padding(.bottom, 6)
                .frame(maxWidth: .infinity)
                .foregroundColor(.brandPrimary)
        }
        .frame(width: 55)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(.gray.opacity(0.1), lineWidth: 1)
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        )
    }
}

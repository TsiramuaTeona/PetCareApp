//
//  StatusRow.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 09.01.26.
//

import SwiftUI

struct StatusRow: View {
    // MARK: - Properties
    
    let icon: String
    let color: Color
    let title: String
    let status: String
    let time: String
    let actionTitle: String
    let actionColor: Color
    
    // MARK: - Body
    
    var body: some View {
        HStack {
            ZStack {
                Circle().fill(color)
                    .frame(width: 40, height: 40)
                Image(systemName: icon)
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.appTitle)
                    .foregroundColor(.textPrimary)
                
                Text(status)
                    .font(.appCaption)
                    .foregroundColor(.textPrimary)
                    .bold()
                
                Text(time)
                    .font(.appCaption)
                    .foregroundColor(.textSecondary)
            }
            
            Spacer()
            
            Button(action: {}) {
                HStack(spacing: 4) {
                    Text(actionTitle)
                    Image(systemName: "chevron.right")
                }
                .font(.appCaption)
                .padding(12)
                .background(actionColor)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
        }
        .shadowCard()
    }
}

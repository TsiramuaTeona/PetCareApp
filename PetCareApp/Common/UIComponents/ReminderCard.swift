//
//  ReminderCard.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 10.01.26.
//


import SwiftUI

struct ReminderCard: View {
    // MARK: - Properties
    
    let item: ReminderItem
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            
            HStack(spacing: 6) {
                Image(systemName: item.log.category.icon)
                    .font(.caption2.weight(.bold))
                    .foregroundColor(item.log.category.color)
                    .padding(4)
                    .background(item.log.category.color.opacity(0.1))
                    .clipShape(Circle())
                
                Text(item.log.category.rawValue.uppercased())
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(item.log.category.color)
                
                Spacer()
                
                Text(item.log.statusText.uppercased())
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(item.log.isUrgent ? .error : .gray)
            }
            
            HStack(alignment: .center, spacing: 12) {
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.log.title)
                        .font(.appTitle)
                        .foregroundColor(.textPrimary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Text("for \(item.petName)")
                        .font(.appCaption)
                        .foregroundColor(.textSecondary)
                }
                
                Spacer()
                
                ImageView(urlString: item.petPhoto, contentMode: .fill)
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                    .overlay(
                        Circle().stroke(Color.gray.opacity(0.1), lineWidth: 1)
                    )
                
                Image(systemName: "chevron.right")
                    .font(.caption2)
                    .foregroundColor(.gray.opacity(0.3))
            }
        }
        .padding(14)
        .background(.surface)
        .cornerRadius(16)
        .shadow(color: .textPrimary.opacity(0.04), radius: 3, x: 0, y: 1)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.06), lineWidth: 1)
        )
    }
}

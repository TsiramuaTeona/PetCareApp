//
//  HistoryLogRow.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 10.01.26.
//


import SwiftUI

struct HistoryLogRow: View {
    // MARK: - Properties
    
    let log: HealthLog
    let onInfoTap: () -> Void
    let onDelete: () -> Void
    
    // MARK: - Body
    
    var body: some View {
        HStack (spacing: 12) {
            Image(systemName: log.category.icon)
                .foregroundColor(log.category.color)
                .font(.appTitle)
            
            VStack(alignment: .leading) {
                Text(log.title)
                    .font(.appTitle)
                    .foregroundColor(.textPrimary)
                
                Text(log.date.formatted(date: .long, time: .shortened))
                    .font(.appCaption)
                    .foregroundColor(.textSecondary)
            }
            
            Spacer()
            
            Button(action: onInfoTap) {
                Image(systemName: "info.circle")
                    .font(.appTitle)
                    .foregroundColor(log.category.color)
            }
        }
        .contextMenu {
            Button(role: .destructive, action: onDelete) {
                Label("Delete", systemImage: "trash")
            }
        }
        .padding(.vertical)
    }
}

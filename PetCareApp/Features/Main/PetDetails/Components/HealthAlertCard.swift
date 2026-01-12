//
//  HealthAlertCard.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 10.01.26.
//


import SwiftUI

struct HealthAlertCard: View {
    
    // MARK: - Properties
    
    let log: HealthLog
    let resolveAction: () -> Void
    
    // MARK: - Body
    
    var body: some View {
        HStack(spacing: 12) {
            
            icon
            content
            
            Spacer()
            
            if log.isActionable {
                resolveButton
            }
        }
        .shadowCard()
    }
    
    // MARK: - Subviews
    
    private var icon: some View {
        ZStack {
            Circle()
                .fill(log.isUrgent ? .error.opacity(0.12) : log.category.color.opacity(0.12))
                .frame(width: 44, height: 44)
            
            Image(systemName: log.category.icon)
                .font(.headline)
                .foregroundColor(log.isUrgent ? .error : log.category.color)
        }
    }
    
    private var content: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(log.title)
                .font(.appTitle)
                .foregroundColor(.textPrimary)
            
            Text(log.statusText)
                .font(.appCaption)
                .foregroundColor(log.isUrgent ? .error.opacity(0.8) : .textSecondary)
        }
    }
    
    private var resolveButton: some View {
        Button(action: resolveAction) {
            HStack(spacing: 6) {
                Image(systemName: "checkmark")
                    .font(.caption.bold())
                
                Text("Done")
                    .font(.appCaption.bold())
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(log.isUrgent ? .error : log.category.color)
            )
            .foregroundColor(.white)
        }
        .buttonStyle(.plain)
    }
}

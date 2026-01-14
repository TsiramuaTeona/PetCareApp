//
//  MedicationCard.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 10.01.26.
//


import SwiftUI

struct MedicationCard: View {
    // MARK: - Properties
    
    let log: HealthLog
    
    // MARK: - Computed Helpers
    
    private var endDate: Date? {
        guard let days = log.durationDays else { return nil }
        return log.date.adding(days: days)
    }
    
    private var durationText: String {
        if let days = log.durationDays {
            return "\(days) days"
        } else {
            return "Ongoing"
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            title
            
            Divider()
                .overlay(.white.opacity(0.3))
            
            infoSection
            
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(log.isUrgent ? .error.opacity(0.9) : .brandPurple)
                .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
        )
    }
    
    // MARK: -  Subview
    
    private var title: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(.white.opacity(0.2))
                    .frame(width: 44, height: 44)
                
                Image(systemName: "pills.fill")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(log.title)
                    .font(.appTitle)
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                Text(log.statusText)
                    .font(.appCaption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white.opacity(0.9))
                
                if let dosage = log.dosage {
                    Text(dosage)
                        .font(.appCaption)
                        .fontWeight(.medium)
                        .foregroundColor(.white.opacity(0.9))
                }
            }
            
            Spacer()
            
            if log.isUrgent {
                Image(systemName: "exclamationmark.circle.fill")
                    .foregroundColor(.error)
                    .font(.title3)
                    .background(
                        Circle()
                            .fill(Color.white)
                            .padding(2)
                    )
            }
        }
    }
    
    private var infoSection: some View {
        HStack(alignment: .top, spacing: 20) {
            VStack(alignment: .leading, spacing: 10) {
                DetailRow(
                    icon: "clock.arrow.2.circlepath",
                    label: "Frequency",
                    value: "\(log.timesPerDay ?? 1)x Daily"
                )
                
                DetailRow(
                    icon: "hourglass",
                    label: "Duration",
                    value: durationText
                )
            }
            
            Divider()
                .frame(height: 30)
                .overlay(Color.white.opacity(0.3))
            
            
            VStack(alignment: .leading, spacing: 10) {
                DetailRow(
                    icon: "calendar",
                    label: "Start",
                    value: log.date.formatted(date: .numeric, time: .omitted)
                )
                
                if let end = endDate {
                    DetailRow(
                        icon: "flag.checkered",
                        label: "End",
                        value: end.formatted(date: .numeric, time: .omitted)
                    )
                } else {
                    DetailRow(
                        icon: "infinity",
                        label: "End",
                        value: "Chronic"
                    )
                }
            }
        }
    }
}

// MARK: - DetailRow Subview

private struct DetailRow: View {
    // MARK: - Properties
    
    let icon: String
    let label: String
    let value: String
    
    // MARK: - Body
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.7))
                .frame(width: 16)
            
            VStack(alignment: .leading, spacing: 0) {
                Text(label)
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.7))
                    .textCase(.uppercase)
                
                Text(value)
                    .font(.appCaption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
        }
    }
}

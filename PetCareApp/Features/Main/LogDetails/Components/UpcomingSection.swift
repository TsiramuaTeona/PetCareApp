//
//  UpcomingSection.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 13.01.26.
//


import SwiftUI

struct UpcomingSection: View {
    // MARK: - Properties
    
    let logs: [HealthLog]
    var resolveAction: (HealthLog) -> Void
    var onEdit: (HealthLog) -> Void
    var onDelete: (HealthLog) -> Void
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeaderView(text: "Upcoming Schedule")
            
            VStack(spacing: 0) {
                list
            }
            .padding(.horizontal)
            .background(.surface)
            .cornerRadius(10)
            .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 5)
        }
    }
    
    // MARK: - Subviews
    
    private var list: some View {
        ForEach(Array(logs.enumerated()), id: \.element.id) { index, log in
            HStack(spacing: 16) {
                CalendarDateView(
                    day: log.nextDueDate?.dayNumber ?? "-",
                    month: log.nextDueDate?.monthAbbreviation ?? "-",
                    year: log.nextDueDate?.yearNumber ?? "-",
                )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(log.nextDueDate?.timeString ?? "All Day")
                        .font(.appTitle)
                        .foregroundColor(.textPrimary)
                    
                    Text(log.note ?? "Scheduled")
                        .font(.appCaption)
                        .foregroundColor(.textSecondary)
                        .lineLimit(1)
                    
                    if let dosage = log.dosage, !dosage.isEmpty {
                        Text("Dosage: \(dosage)")
                            .font(.appCaption)
                            .foregroundColor(log.category.color)
                            .lineLimit(1)
                    }
                }
                
                Spacer()
                
                if log.isActionable {
                    Button(
                        "",
                        role: log.isUrgent ? .destructive : .none,
                        action: { resolveAction(log) }
                    )
                    .buttonStyle(.resolve(categoryColor: log.category.color))
                }
            }
            .padding(.vertical)
            .contentShape(Rectangle())
            .onTapGesture { onEdit(log) }
            
            if index < logs.count - 1 {
                Divider()
            }
        }
    }
}

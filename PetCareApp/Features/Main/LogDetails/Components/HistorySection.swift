//
//  HistorySection.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 13.01.26.
//


import SwiftUI

struct HistorySection: View {
    // MARK: - Properties
    
    let logs: [HealthLog]
    var onEdit: (HealthLog) -> Void
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeaderView(text: "History")
            
            VStack(spacing: 0) {
                if logs.isEmpty {
                    emptyState
                } else {
                    ForEach(Array(logs.enumerated()), id: \.element.id) { index, log in
                        HStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(.success.opacity(0.1))
                                    .frame(width: 36, height: 36)
                                
                                Image(systemName: "checkmark")
                                    .font(.caption.weight(.bold))
                                    .foregroundColor(.success)
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(log.date.mediumDateString)
                                    .font(.appBody)
                                    .foregroundColor(.textPrimary)
                                
                                Text(log.date.timeString)
                                    .font(.caption)
                                    .foregroundColor(.textSecondary)
                            }
                            
                            Spacer()
                            
                            if let value = log.value {
                                Text("\(String(format: "%.1f", value)) kg")
                                    .font(.appBody)
                                    .fontWeight(.medium)
                                
                            } else if let dosage = log.dosage, !dosage.isEmpty {
                                Text(dosage)
                                    .font(.appCaption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(.brandPurple.opacity(0.3))
                                    .cornerRadius(6)
                            }
                        }
                        .padding(.vertical, 12)
                        .contentShape(Rectangle())
                        .onTapGesture { onEdit(log) }
                        
                        if let note = log.note, !note.isEmpty {
                            Text(note)
                                .font(.appCaption)
                                .foregroundColor(.textSecondary)
                                .padding(.bottom, 12)
                        }
                        
                        if index < logs.count - 1 {
                            Divider()
                        }
                    }
                }
            }
            .padding(.horizontal, 12)
            .background(.surface)
            .cornerRadius(10)
            .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 5)
        }
    }
    
    // MARK: - Subviews
    
    private var emptyState: some View {
        HStack {
            Spacer()
            VStack(spacing: 8) {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.largeTitle)
                    .foregroundColor(.textSecondary.opacity(0.3))
                
                Text("No history yet")
                    .font(.appCaption)
                    .foregroundColor(.textSecondary)
            }
            .padding(.vertical, 20)
            Spacer()
        }
    }
}

//
//  DetailsSection.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 13.01.26.
//


import SwiftUI

struct DetailsSection: View {
    // MARK: - Properties
    
    @ObservedObject var viewModel: LogDetailsViewModel
    
    // MARK: - Body
    
    var body: some View {
        SectionHeaderView(text: "Details")
        
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(viewModel.sourceLog.category.color)
                        .opacity(0.15)
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: viewModel.categoryIcon)
                        .font(.title2)
                        .foregroundColor(viewModel.sourceLog.category.color)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.sourceLog.title)
                        .font(.appHeader)
                        .foregroundColor(.textPrimary)
                    
                    Text(viewModel.categoryText)
                        .font(.appBody)
                        .foregroundColor(.textSecondary)
                }
                
                Spacer()
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 12) {
                if let dosage = viewModel.sourceLog.dosage, !dosage.isEmpty {
                    Label("Dosage - \(dosage)", systemImage: "pills")
                }
                
                if let value = viewModel.sourceLog.value, !viewModel.isWeightCategory {
                    Label("Value - \(String(format: "%.1f", value)) kg", systemImage: "scalemass")
                }
                
                if let recurrence = viewModel.sourceLog.recurrence {
                    Label("Freqency - \(recurrence.rawValue.capitalized)", systemImage: "repeat")
                }
                
                if let times = viewModel.sourceLog.timesPerDay, times > 0, !viewModel.isWeightCategory {
                    Label("\(times)x per day", systemImage: "clock.arrow.circlepath")
                }
                
                if let duration = viewModel.sourceLog.durationDays {
                    Label("Duration - \(duration) days", systemImage: "hourglass")
                }
            }
            .font(.appBody)
            
            if let note = viewModel.sourceLog.note, !note.isEmpty {
                Divider()
                
                VStack(alignment: .leading, spacing: 8) {
                    Label("Note", systemImage: "text.alignleft")
                        .font(.appCaption)
                        .fontWeight(.bold)
                        .foregroundColor(.textSecondary)
                    
                    Text(note)
                        .font(.appBody)
                        .foregroundColor(.textPrimary)
                }
            }
        }
        .shadowCard()
    }
}

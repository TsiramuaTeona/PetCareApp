//
//  ReminderSection.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 12.01.26.
//

import SwiftUI

struct ReminderSection: View {
    // MARK: - Properties
    
    @ObservedObject var viewModel: AddHealthLogViewModel
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeaderView(text: "Future Planning")
            
            VStack(spacing: 4) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(viewModel.reminderLabel)
                            .font(.appTitle)
                            .foregroundColor(.textPrimary)
                    }
                    
                    Spacer()
                    
                    Toggle("", isOn: $viewModel.addReminder)
                        .labelsHidden()
                        .tint(.brandPrimary)
                }
                .borderedSection()
                
                if viewModel.addReminder && !viewModel.isMedication {
                    
                    if viewModel.isHistoryLog {
                        DatePicker(
                            "Next Due Date",
                            selection: $viewModel.nextDueDate,
                            in: Date()...,
                            displayedComponents: .date
                        )
                        .font(.appTitle)
                        .foregroundColor(.textPrimary)
                        .borderedSection()
                    }
                    
                    HStack {
                        Text("Repeat")
                            .font(.appTitle)
                            .foregroundColor(.textPrimary)
                        
                        Spacer()
                        
                        Picker("Repeat", selection: $viewModel.recurrence) {
                            ForEach(RecurrenceRule.allCases) { rule in
                                Text(rule.rawValue).tag(rule)
                            }
                        }
                        .labelsHidden()
                        .disabled(!viewModel.addReminder)
                    }
                    .borderedSection()
                }
            }
        }
    }
}

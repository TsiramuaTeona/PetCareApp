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
        content
    }
    
    // MARK: - Subviews
    
    private var content: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeaderView(text: "Future Planning")
            
            VStack(spacing: 4) {
                
                reminderLabelSection
                
                if viewModel.addReminder && !viewModel.isMedication {
                    
                    if viewModel.isHistoryLog {
                        datePickerSection
                    }
                    
                    timePickerSection
                }
            }
        }
    }
    
    private var reminderLabelSection: some View {
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
    }
    
    private var datePickerSection: some View {
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
    
    private var timePickerSection: some View {
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

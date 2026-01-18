//
//  MedicationDetailsSection.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 12.01.26.
//

import SwiftUI

struct MedicationDetailsSection: View {
    // MARK: - Properties
    
    @ObservedObject var viewModel: AddHealthLogViewModel
    
    // MARK: - Body
    
    var body: some View {
        content
    }
    
    // MARK: - Subviews
    
    private var content: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeaderView(text: "Schedule")
            
            PrimaryTextField(
                title: "Medication Name",
                placeholder: "e.g. Amoxicillin",
                text: $viewModel.title
            )
            
            PrimaryTextField(
                title: "Dosage",
                placeholder: "e.g. 1 pill",
                text: $viewModel.dosage
            )
            
            frequencyPicker
            
            ToggleRow(title: "Chronic Condition", isOn: $viewModel.isChronic)
            
            if !viewModel.isChronic {
                durationSection
            }
        }
    }
    
    private var frequencyPicker: some View {
        HStack {
            Text("Frequency")
                .font(.appTitle)
                .foregroundColor(.textPrimary)
            
            Spacer()
            
            Stepper(
                "\(viewModel.timesPerDay)x daily",
                value: $viewModel.timesPerDay,
                in: 1...4
            )
            .labelsHidden()
            
            Text("\(viewModel.timesPerDay)x daily")
                .foregroundColor(.brandPrimary)
                .font(.appBody)
        }
        .borderedSection()
    }
    
    private var durationSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Duration: \(Int(viewModel.durationDays)) days")
                .font(.appBody)
                .foregroundColor(.textSecondary)
            
            Slider(value: $viewModel.durationDays, in: 1...30, step: 1)
                .tint(.brandPrimary)
        }
        .borderedSection()
    }
}

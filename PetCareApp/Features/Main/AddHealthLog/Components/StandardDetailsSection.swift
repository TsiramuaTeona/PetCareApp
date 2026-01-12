//
//  StandardDetailsSection.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 12.01.26.
//


import SwiftUI

struct StandardDetailsSection: View {
    // MARK: - Properties
    
    @ObservedObject var viewModel: AddHealthLogViewModel
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeaderView(text: "Details")
            
            if viewModel.hasValueField {
                HStack(spacing: 12) {
                    PrimaryTextField(
                        title: "Value",
                        placeholder: "0.0 kg",
                        text: $viewModel.valueString
                    )
                    .keyboardType(.decimalPad)
                }
            }
            
            if viewModel.category != .weight {
                VStack(alignment: .leading, spacing: 0) {
                    PrimaryTextField(
                        title: "Title",
                        placeholder: viewModel.titlePlaceholder,
                        text: $viewModel.title
                    )
                    
                    if !viewModel.titleSuggestions.isEmpty {
                        SuggestionChips(
                            suggestions: viewModel.titleSuggestions,
                            onSelect: { suggestion in
                                viewModel.title = suggestion
                            }
                        )
                    }
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Notes")
                    .font(.appBody)
                    .foregroundColor(.textSecondary)
                
                TextField("Optional notes...", text: $viewModel.note, axis: .vertical)
                    .lineLimit(3...6)
                    .borderedSection()
            }
        }
    }
}
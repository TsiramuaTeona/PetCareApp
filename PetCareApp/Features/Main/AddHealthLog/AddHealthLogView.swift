//
//  AddHealthLogView.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 10.01.26.
//


import SwiftUI

struct AddHealthLogView: View {
    // MARK: - Properties
    
    @StateObject var viewModel: AddHealthLogViewModel
    @Environment(\.dismiss) var dismiss
    
    // MARK: - Body
    
    var body: some View {
        content
    }
    
    // MARK: - Subviews
    
    private var content: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    Text("Please fill in the details below to add a new \(viewModel.isMedication ? "medication" : "health log").")
                        .font(.appBody)
                        .foregroundColor(.textSecondary)
                        .multilineTextAlignment(.center)
                    
                    CategorySection(viewModel: viewModel)
                    
                    if viewModel.isMedication {
                        MedicationDetailsSection(viewModel: viewModel)
                    } else {
                        StandardDetailsSection(viewModel: viewModel)
                    }
                    
                    if !viewModel.isMedication && !viewModel.isWeight {
                        ReminderSection(viewModel: viewModel)
                    }
                    
                    ErrorView(message: viewModel.errorMessage)
                    PrimaryButton(
                        title: "Save",
                        isLoading: viewModel.isLoading
                    ) {
                        Task { await viewModel.save() }
                    }
                }
                .padding(24)
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle(viewModel.isMedication ? "Add Medication" : "Add Health Log")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.textSecondary)
                }
            }
        }
    }
}

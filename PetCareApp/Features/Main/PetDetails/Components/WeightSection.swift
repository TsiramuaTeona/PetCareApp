//
//  WeightSection.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 12.01.26.
//


import SwiftUI

struct WeightSection: View {
    // MARK: - Properties
    
    @ObservedObject var viewModel: PetDetailsViewModel
    @Environment(\.navigate) var navigate
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            title
            
            if viewModel.weightLogs.isEmpty{
                noDataView
            } else {
                WeightChart(
                    logs: viewModel.weightLogs,
                    onDelete: { logToDelete in
                        Task {
                            await viewModel.deleteLog(logToDelete)
                        }
                    }
                )
            }
        }
    }
    
    // MARK: - Subviews
    
    private var title: some View {
        HStack {
            Text("Weight Progress")
                .font(.appHeader)
            
            Spacer()
            
            Button {
                navigate(.addHealthLog(petId: viewModel.petId, category: .weight) {
                    Task { await viewModel.refresh() }
                })
            } label: {
                Image(systemName: "plus")
                    .foregroundColor(.white)
                    .padding(8)
                    .background(.brandGreen)
                    .clipShape(Circle())
                    .shadow(color: .textPrimary.opacity(0.08), radius: 10, x: 0, y: 5)
            }
        }
    }
    
    private var noDataView: some View {
        Text("Add weight entries to track your pet's progress over time.")
            .font(.appCaption)
            .foregroundColor(.textSecondary)
            .multilineTextAlignment(.center)
            .padding()
            .shadowCard()
            .frame(maxWidth: .infinity)
    }
}

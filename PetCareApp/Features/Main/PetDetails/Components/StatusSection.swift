//
//  StatusSection.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 12.01.26.
//


import SwiftUI

struct StatusSection: View {
    
    // MARK: - Properties
    
    @ObservedObject var viewModel: PetDetailsViewModel
    @Environment(\.navigate) var navigate
    
    @State private var visibleCount: Int = 5
    
    private var visibleLogs: ArraySlice<HealthLog> {
        viewModel.historyLogs.prefix(visibleCount)
    }
    
    private var canShowMore: Bool {
        visibleCount < viewModel.historyLogs.count
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            header
            
            if viewModel.historyLogs.isEmpty {
                emptyState
            } else {
                logsList
                
                if canShowMore {
                    showMoreButton
                }
            }
        }
    }
    
    // MARK: - Subviews
    
    private var header: some View {
        HStack {
            Text("Health & Care Log")
                .font(.appHeader)
            
            Spacer()
            
            Button("Add Log") {
                navigate(.addHealthLog(petId: viewModel.petId) {
                    Task { await viewModel.refresh() }
                })
            }
            .font(.appCaption)
            .fontWeight(.bold)
            .buttonStyle(.borderedProminent)
            .tint(.brandPrimary)
        }
    }
    
    private var logsList: some View {
        VStack(spacing: 0) {
            ForEach(visibleLogs) { log in
                HistoryLogRow(
                    log: log,
                    onInfoTap: {
                        navigate(
                            .logDetails(petId: viewModel.petId, petName: viewModel.pet.name, log: log)
                        )
                    },
                    onDelete: {
                        Task { await viewModel.deleteLog(log) }
                    }
                )
                
                Divider()
            }
        }
        .animation(.easeInOut, value: visibleCount)
    }
    
    private var showMoreButton: some View {
        Button {
            visibleCount += 5
        } label: {
            Text("Show more")
                .font(.appCaption.bold())
                .foregroundColor(.brandPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
        }
    }
    
    private var emptyState: some View {
        Text("No logs yet. Track vaccines, medications, and more.")
            .font(.appCaption)
            .foregroundColor(.textSecondary)
    }
}

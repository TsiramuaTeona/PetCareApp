//
//  LogDetailsView.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 13.01.26.
//


import SwiftUI

struct LogDetailsView: View {
    // MARK: - Properties
    
    @StateObject var viewModel: LogDetailsViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var logToEdit: HealthLog?
    
    // MARK: - Body
    
    var body: some View {
        ScreenStateContainer(
            state: viewModel.state,
            onRetry: { await viewModel.refresh() }
        ) {
            content
        }
        .navigationBarHidden(false)
        .navigationTitle(viewModel.sourceLog.title)
        .toolbar {
            Button {
                viewModel.requestAddToCalendar()
            } label: {
                Image(systemName: "calendar.badge.plus")
            }
        }
        .alert(item: $viewModel.alert) { $0.toAlert() }
        .task { await viewModel.refresh() }
        .sheet(item: $logToEdit) { log in
            EditLogView(
                log: log,
                onSave: { newDate, newNote, valueString, dosage in
                    Task {
                        await viewModel.saveLogEdits(
                            originalLog: log,
                            newDate: newDate,
                            newNote: newNote,
                            valueString: valueString,
                            dosage: dosage
                        )
                        
                        logToEdit = nil
                    }
                },
                onDelete: {
                    Task {
                        await viewModel.deleteLog(log)
                        logToEdit = nil
                    }
                }
            )
        }
    }
    
    // MARK: - Subviews
    
    private var content: some View {
        ScrollView {
            VStack(spacing: 16) {
                if viewModel.isWeightCategory {
                    weightSection
                }
                
                DetailsSection(viewModel: viewModel)
                
                if !viewModel.upcomingLogs.isEmpty {
                    UpcomingSection(
                        logs: viewModel.upcomingLogs,
                        resolveAction: { log in
                            Task {
                                await viewModel.resolveLog(log)
                            }
                        },
                        onEdit: { log in
                            logToEdit = log
                        },
                        onDelete: { log in
                            Task { await viewModel.deleteLog(log) }
                        }
                    )
                }
                
                HistorySection(
                    logs: viewModel.historyLogs,
                    onEdit: { log in
                        logToEdit = log
                    }
                )
                
                Spacer(minLength: 40)
            }
            .padding(24)
        }
    }
    
    private var weightSection: some View {
        WeightChart(logs: viewModel.chartData, onDelete: { log in
            Task {
                await viewModel.deleteLog(log)
            }
        })
    }
}

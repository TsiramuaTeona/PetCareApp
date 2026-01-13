//
//  MedicationSection.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 12.01.26.
//


import SwiftUI

struct MedicationSection: View {
    // MARK: - Properties
    
    @ObservedObject var viewModel: PetDetailsViewModel
    @Environment(\.navigate) var navigate
    
    // MARK: - Body
    
    var body: some View {
        return Group {
            if !viewModel.medicationLogs.isEmpty {
                VStack(alignment: .leading, spacing: 0) {
                    title
                    
                    medicationList
                }
            }
        }
    }
    
    // MARK: - Subviews
    
    private var title: some View {
        HStack {
            Text("Medications")
                .font(.appHeader)
            
            Spacer()
            
            Button {
                navigate(.addHealthLog(petId: viewModel.petId, category: .medication) {
                    Task { await viewModel.refresh() }
                })
            } label: {
                Image(systemName: "plus")
                    .foregroundColor(.white)
                    .padding(8)
                    .background(.brandPurple)
                    .clipShape(Circle())
                    .shadow(color: .textPrimary.opacity(0.08), radius: 10, x: 0, y: 5)
            }
        }
    }
    
    private var medicationList: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(viewModel.medicationLogs) { log in
                    MedicationCard(log: log)
                        .onTapGesture {
                            navigate(.logDetails(petId: viewModel.petId, log: log))
                        }
                }
            }
            .padding(.vertical)
            .padding(.horizontal, 24)
        }
        .padding(.horizontal, -24)
    }
        
}

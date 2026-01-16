//
//  UpcomingAlertsSection.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 12.01.26.
//



import SwiftUI

struct UpcomingAlertsSection: View {
    // MARK: - Properties
    
    @ObservedObject var viewModel: PetDetailsViewModel
    @Environment(\.navigate) private var navigate
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Up Next")
                .font(.appHeader)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.upcomingAlerts) { log in
                        HealthAlertCard(log: log) {
                            Task { await viewModel.resolveLog(log) }
                        }
                        .onTapGesture {
                            navigate(.logDetails(petId: viewModel.petId, petName: viewModel.pet.name, log: log))
                        }
                    }
                }
                .padding(.vertical, 16)
                .padding(.horizontal, 24)
            }
            .padding(.horizontal, -24)
        }
    }
}

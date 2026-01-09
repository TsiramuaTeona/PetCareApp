//
//  HouseholdInfoSection.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 06.01.26.
//


import SwiftUI

struct HouseholdInfoSection: View {
    // MARK: - Properties
    
    @ObservedObject var viewModel: ProfileViewModel
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Label("My Household", systemImage: "house.fill")
                    .font(.appHeader)
                
                Spacer()
                
                Button {
                    Task {
                        await viewModel.leaveHousehold()
                    }
                } label: {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .foregroundColor(.brandPrimary)
                        .font(.appHeader)
                }
            }
            
            Divider()
            
            HStack {
                Text(viewModel.householdName)
                    .font(.appTitle)
                
                Spacer()
                
                Text("\(viewModel.householdMemberCount) Members")
                    .font(.appBody)
                    .foregroundColor(.textSecondary)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("INVITE CODE")
                    .font(.appCaption)
                    .fontWeight(.bold)
                    .foregroundColor(.textSecondary)
                
                HStack {
                    Text(viewModel.householdJoinCode)
                        .font(.appHeader)
                        .foregroundColor(.brandPrimary)
                    
                    Spacer()
                    
                    Button {
                        UIPasteboard.general.string = viewModel.householdJoinCode
                    } label: {
                        Image(systemName: "doc.on.doc")
                            .foregroundColor(.brandPrimary)
                    }
                }
                .padding()
                .background(.brandPrimary.opacity(0.1))
                .cornerRadius(10)
            }
        }
        .shadowCard()
    }
}

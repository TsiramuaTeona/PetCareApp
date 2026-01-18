//
//  NoHouseholdSection.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 06.01.26.
//

import SwiftUI

struct NoHouseholdSection: View {
    // MARK: - Properties
    
    @ObservedObject var viewModel: ProfileViewModel
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 16) {
            Text("No Household Yet")
                .font(.appHeader)
            
            VStack(alignment: .leading) {
                Text("Create New")
                    .font(.appTitle)
                    .foregroundColor(.textPrimary)
                
                HStack {
                    TextField("Family Name", text: $viewModel.newHouseholdName)
                        .autocorrectionDisabled()
                        .padding(8)
                        .background(.surface)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(.brandSecondary, lineWidth: 1)
                        )
                    
                    Button("Create") {
                        Task { await viewModel.createHousehold() }
                    }
                    .buttonStyle(.borderedProminent)
                    .font(.appButton)
                    .tint(.brandSecondary)
                }
            }
            
            Divider()
            
            VStack(alignment: .leading) {
                Text("Join Existing")
                    .font(.appTitle)
                    .foregroundColor(.textPrimary)
                
                HStack {
                    CodeInputView(code: $viewModel.joinCodeInput, length: 6)
                    
                    Button("Join") {
                        Task { await viewModel.joinHousehold() }
                    }
                    .buttonStyle(.bordered)
                    .font(.appButton)
                    .tint(.brandSecondary)
                }
            }
        }
        .shadowCard()
    }
}

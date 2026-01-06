//
//  ProfileView.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 05.01.26.
//


import SwiftUI

struct ProfileView: View {
    // MARK: - Properties
    
    @StateObject var viewModel: ProfileViewModel
    
    // MARK: - Body
    
    var body: some View {
        ScreenStateContainer(
            state: viewModel.state,
            onRetry: {
                await viewModel.loadProfile()
            }
        ) {
            content
        }
        .navigationTitle("Profile")
        .task {
            await viewModel.loadProfile()
        }
        .alert(item: $viewModel.activeAlert) { alertType in
            switch alertType {
            case .error(let message):
                return Alert(title: Text("Error"), message: Text(message), dismissButton: .default(Text("OK")))
            case .success(let message):
                return Alert(title: Text("Success"), message: Text(message), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    // MARK: - Subviews
    
    private var content: some View {
        ScrollView {
            VStack(spacing: 24) {
                
                userInfoSection
                
                if viewModel.household != nil {
                    HouseholdInfoSection(viewModel: viewModel)
                } else {
                    NoHouseholdSection(viewModel: viewModel)
                }
            }
            .padding(.horizontal, 24)
        }
        .scrollDismissesKeyboard(.interactively)
    }
    
    private var userInfoSection: some View {
        VStack(spacing: 16) {
            Image("AppLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
            
            Text(viewModel.user?.fullName ?? "User")
                .font(.appHeader)
            
            Label(viewModel.user?.email ?? "", systemImage: "envelope.fill")
                .font(.appCaption)
                .foregroundColor(.textSecondary)
            
            Divider()
            
            PrimaryButton(title: "Logout", isLoading: false) {
                Task {
                    await viewModel.signOut()
                }
            }
        }
        .shadowCard()
    }
}

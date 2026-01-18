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
            onRetry: { await viewModel.loadProfile() }
        ) {
            content
        }
        .navigationTitle("Profile")
        .task { await viewModel.loadProfile() }
        .alert(item: $viewModel.alert) { $0.toAlert() }
    }
    
    // MARK: - Subviews
    
    private var content: some View {
        ScrollView {
            VStack(spacing: 24) {
                
                userInfoSection
                
                if viewModel.isUserInHousehold {
                    HouseholdInfoSection(viewModel: viewModel)
                } else {
                    NoHouseholdSection(viewModel: viewModel)
                }
                
                appearanceSection
                
                Spacer()
                    .frame(height: 40)
            }
            .padding(.horizontal, 24)
        }
        .scrollDismissesKeyboard(.interactively)
    }
    
    private var userInfoSection: some View {
        ZStack(alignment: .topTrailing) {
            Group {
                if viewModel.isEditingProfile {
                    HStack {
                        Button {
                            withAnimation(.snappy) {
                                viewModel.cancelEditingProfile()
                            }
                        } label: {
                            Image(systemName: "xmark")
                                .foregroundColor(.textSecondary)
                                .font(.appHeader)
                        }
                        
                        Spacer()
                        
                        Button {
                            Task { await viewModel.saveProfileChanges() }
                        } label: {
                            Image(systemName: "checkmark")
                                .font(.appHeader)
                        }
                        .buttonStyle(.borderless)
                        .tint(.brandPrimary)
                        .disabled(viewModel.canSaveProfile == false)
                    }
                    .transition(.move(edge: .top).combined(with: .opacity))
                } else {
                    Button {
                        withAnimation(.snappy) {
                            viewModel.startEditingProfile()
                        }
                    } label: {
                        Image(systemName: "pencil")
                            .foregroundColor(.brandPrimary)
                            .font(.appHeader)
                    }
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .padding(.top, 2)
            
            VStack(spacing: 16) {
                Group {
                    if viewModel.isEditingProfile {
                        PhotoPickerView(
                            imageData: $viewModel.draftImageData,
                            imageURL: viewModel.user?.photoUrl,
                            size: 90
                        )
                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                    } else {
                        if let url = viewModel.user?.photoUrl, url.isEmptyOrWhitespace == false {
                            ImageView(urlString: url, contentMode: .fill)
                                .frame(width: 90, height: 90)
                                .clipShape(Circle())
                                .transition(.opacity.combined(with: .scale(scale: 0.95)))
                        } else {
                            Image("AppLogo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 90, height: 90)
                                .transition(.opacity.combined(with: .scale(scale: 0.95)))
                        }
                    }
                }
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                
                Group {
                    if viewModel.isEditingProfile {
                        PrimaryTextField(
                            title: "Name",
                            placeholder: "Enter your name",
                            text: $viewModel.draftFullName
                        )
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    } else {
                        VStack(spacing: 8) {
                            Text(viewModel.userFullName)
                                .font(.appHeader)
                            
                            Label(viewModel.userEmail, systemImage: "envelope.fill")
                                .font(.appCaption)
                                .foregroundColor(.textSecondary)
                        }
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
                
                if !viewModel.isEditingProfile {
                    Divider()
                        .transition(.opacity)
                    
                    Button("Logout") {
                        Task { await viewModel.signOut() }
                    }
                    .buttonStyle(.primary(isLoading: false))
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .padding(.top, 8)
        }
        .shadowCard()
        .animation(.snappy, value: viewModel.isEditingProfile)
    }

    
    private var appearanceSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            HStack {
                Label("Appearance", systemImage: "paintbrush.fill")
                    .font(.appTitle)
                    .foregroundColor(.brandSecondary)
                
                Spacer()
                
                Text("Theme")
                    .font(.appCaption)
                    .foregroundColor(.textSecondary)
            }
            
            HStack(spacing: 12) {
                ThemeOptionCard(
                    theme: .system,
                    selected: viewModel.selectedTheme,
                    action: { selectTheme(.system) }
                )
                
                ThemeOptionCard(
                    theme: .light,
                    selected: viewModel.selectedTheme,
                    action: { selectTheme(.light) }
                )
                
                ThemeOptionCard(
                    theme: .dark,
                    selected: viewModel.selectedTheme,
                    action: { selectTheme(.dark) }
                )
            }
            
            HStack(spacing: 8) {
                Image(systemName: "iphone")
                    .foregroundColor(.textSecondary)
                Text("System follows your iPhone settings.")
                    .font(.appCaption)
                    .foregroundColor(.textSecondary)
            }
        }
        .shadowCard()
    }
    
    // MARK: - Actions
    
    private func selectTheme(_ theme: AppTheme) {
        withAnimation(.snappy) {
            viewModel.selectedTheme = theme
        }
    }
}

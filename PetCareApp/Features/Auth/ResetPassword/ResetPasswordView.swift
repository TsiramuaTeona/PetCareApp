//
//  ResetPasswordView.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 03.01.26.
//


import SwiftUI

struct ResetPasswordView: View {
    // MARK: - Properties
    
    @StateObject var viewModel: ResetPasswordViewModel
    @Environment(\.dismiss) private var dismiss
    
    @FocusState private var isEmailFocused: Bool
    
    // MARK: - Body
    
    var body: some View {
        content
            .background(.mainBackground)
            .scrollDismissesKeyboard(.interactively)
            .alert("Success", isPresented: $viewModel.showSuccessAlert) {
                Button("OK", action: dismiss.callAsFunction)
            } message: {
                Text("Reset link has been sent. Please check your email.")
            }
    }
    
    // MARK: - Subviews
    
    private var content: some View {
        ScrollView {
            VStack(spacing: 16) {
                AuthHeader(
                    title: "Forgot Password?",
                    subtitle: "Enter your email and we'll send you a link to reset your password."
                )
                formSection
            }
            .padding(24)
        }
    }
    
    @ViewBuilder
    private var formSection: some View {
        PrimaryTextField(
            title: "Email Address",
            placeholder: "name@example.com",
            text: $viewModel.email,
            keyboardType: .emailAddress,
        )
        .focused($isEmailFocused)
        
        ErrorView(message: viewModel.errorMessage)
        
        Spacer()
        
        PrimaryButton(
            title: "Send Reset Link",
            isLoading: viewModel.isLoading
        ) {
            isEmailFocused = false
            Task {
                await viewModel.resetPassword()
            }
        }
        
        Button {
            dismiss()
        } label: {
            Label("Back to Login", systemImage: "arrow.left")
                .font(.appBody)
                .foregroundColor(.brandSecondary)
        }
    }
}

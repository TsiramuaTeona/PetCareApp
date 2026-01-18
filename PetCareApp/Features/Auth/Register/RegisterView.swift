//
//  RegisterView.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 03.01.26.
//


import SwiftUI

struct RegisterView: View {
    // MARK: - Properties
    
    @StateObject var viewModel: RegisterViewModel
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Body
    var body: some View {
        content
            .background(.mainBackground)
            .scrollDismissesKeyboard(.interactively)
            .alert("Account created", isPresented: $viewModel.showSuccessAlert) {
                Button("OK", action: dismiss.callAsFunction)
            } message: {
                Text("Your account has been created successfully.")
            }
    }
    
    // MARK: - Subviews
    
    private var content: some View {
        ScrollView {
            VStack(spacing: 6) {
                AuthHeader(
                    title: "Create Account",
                    subtitle: "Enter your details to get started."
                )
                formSection
            }
            .padding(24)
        }
    }
    
    @ViewBuilder
    private var formSection: some View {
        PrimaryTextField(
            title: "Full Name",
            placeholder: "Name Surname",
            text: $viewModel.fullName,
            errorMessage: viewModel.fieldErrors[.fullName]?.localizedDescription
        )
        
        PrimaryTextField(
            title: "Email Address",
            placeholder: "name@example.com",
            text: $viewModel.email,
            keyboardType: .emailAddress,
            errorMessage: viewModel.fieldErrors[.email]?.localizedDescription
        )
        
        PrimaryTextField(
            title: "Password",
            placeholder: "Create password",
            text: $viewModel.password,
            isSecure: true,
            errorMessage: viewModel.fieldErrors[.password]?.localizedDescription
        )
        
        PrimaryTextField(
            title: "Confirm Password",
            placeholder: "Confirm password",
            text: $viewModel.confirmPassword,
            isSecure: true,
            errorMessage: viewModel.fieldErrors[.confirmPassword]?.localizedDescription
        )
        
        ErrorView(message: viewModel.formError)
        
        Button("Sign Up") {
            Task { await viewModel.register() }
        }
        .buttonStyle(.primary(isLoading: viewModel.isLoading))
        .disabled(viewModel.isLoading)
        
        Button {
            dismiss()
        } label: {
            HStack {
                Text("Already have an account?")
                Text("Sign In")
                    .font(.appButton)
            }
            .font(.appBody)
            .foregroundColor(.brandSecondary)
        }
    }
}

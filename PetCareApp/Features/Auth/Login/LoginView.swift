//
//  LoginView.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 03.01.26.
//


import SwiftUI

struct LoginView: View {
    // MARK: - Properties
    
    @StateObject var viewModel: LoginViewModel
    @Environment(\.navigate) private var navigate
    
    // MARK: - Body
    
    var body: some View {
        content
            .background(.mainBackground)
            .scrollDismissesKeyboard(.interactively)
    }
    
    // MARK: - Subviews
    
    private var content: some View {
        ScrollView {
            VStack(spacing: 16) {
                AuthHeader(title: "Welcome Back")
                formSection
            }
            .padding(24)
        }
    }
    
    @ViewBuilder
    private var formSection: some View {
        VStack(alignment: .trailing, spacing: 8) {
            PrimaryTextField(
                title: "Email Address",
                placeholder: "name@example.com",
                text: $viewModel.email,
                keyboardType: .emailAddress,
                errorMessage: viewModel.fieldErrors[.email]?.localizedDescription
            )
            
            PrimaryTextField(
                title: "Password",
                placeholder: "Enter your password",
                text: $viewModel.password,
                isSecure: true,
                errorMessage: viewModel.fieldErrors[.password]?.localizedDescription
            )
            
            Button {
                navigate(.resetPassword)
            } label: {
                Text("Forgot Password?")
                    .font(.appCaption)
                    .foregroundColor(.brandSecondary)
            }
            
            ErrorView(message: viewModel.formError)
        }
        
        Spacer()
        
        PrimaryButton(
            title: "Log In",
            isLoading: viewModel.isLoading,
        ) {
            Task {
                await viewModel.login()
            }
        }
        
        HStack {
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(.textSecondary)
            
            Text("Or Continue with")
                .font(.appCaption)
                .foregroundColor(.textSecondary)
            
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(.textSecondary)
        }
        .padding(.vertical, 8)
        
        SocialButton(
            title: "Google",
            iconName: "Google",
            isLoading: viewModel.isLoading,
            action: viewModel.googleButtonTapped
        )
        
        Button {
            navigate(.register)
        } label: {
            HStack {
                Text("Don't have an account?")
                Text("Sign Up")
                    .font(.appButton)
            }
            .font(.appBody)
            .foregroundColor(.brandSecondary)
        }
    }
}

//
//  PrimaryTextField.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 03.01.26.
//


import SwiftUI

struct PrimaryTextField: View {
    // MARK: - Properties
    
    let title: String
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    var keyboardType: UIKeyboardType = .default
    var errorMessage: String? = nil
    
    @State private var isPasswordVisible: Bool = false
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            
            Text(title)
                .font(.appTitle)
                .foregroundColor(.textPrimary)
            
            HStack {
                if isSecure && !isPasswordVisible {
                    SecureField(placeholder, text: $text)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                } else {
                    TextField(placeholder, text: $text)
                        .textInputAutocapitalization(.words)
                        .keyboardType(keyboardType)
                        .autocorrectionDisabled()
                }
                
                if isSecure {
                    Button {
                        isPasswordVisible.toggle()
                    } label: {
                        Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                            .foregroundColor(.textSecondary)
                    }
                }
            }
            .padding()
            .background(.surface)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(borderColor, lineWidth: 1)
            )
            
            ErrorText(error: errorMessage, visible: errorMessage != nil)
        }
        .animation(.easeInOut, value: errorMessage != nil)
    }
    
    // MARK: - Helpers
    
    private var borderColor: Color {
        if let errorMessage = errorMessage, !errorMessage.isEmpty {
            return .error
        }
        return .brandSecondary
    }
}

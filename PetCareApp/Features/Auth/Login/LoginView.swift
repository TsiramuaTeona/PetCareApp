//
//  LoginView.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 03.01.26.
//

import SwiftUI

struct LoginView: View {
    // MARK: - Properties
    
    @Environment(\.navigate) private var navigate
    
    @StateObject var viewModel: LoginViewModel
    
    // MARK: - Body
    
    var body: some View {
        VStack {
            Text("Login View")
                .font(.largeTitle)
                .padding()
            
            Button(action: {
                navigate(.mainTabs)
            }) {
                Text("Log In")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(.blue)
                    .cornerRadius(10)
            }
            
            Button("Sign in with Google") {
                viewModel.googleButtonTapped()
            }
        }
    }
}

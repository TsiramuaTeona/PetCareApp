//
//  AddPetView.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 05.01.26.
//


import SwiftUI
import PhotosUI

struct AddPetView: View {
    // MARK: - Properties
    
    @StateObject var viewModel: AddPetViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedItem: PhotosPickerItem?
    
    // MARK: - Body
    
    var body: some View {
        ScrollView {
            content
        }
        .background(.mainBackground)
        .navigationBarHidden(false)
        .navigationTitle("Add New Family Member")
        .scrollDismissesKeyboard(.interactively)
        .onChange(of: viewModel.shouldDismiss) { _, shouldDismiss in
            if shouldDismiss {
                dismiss()
            }
        }
    }
    
    // MARK: - Subviews
    
    private var content: some View {
        VStack(spacing: 16) {
            PhotoPickerView(
                imageData: $viewModel.photoData,
                size: 120
            )
            
            formSection
        }
        .padding(24)
    }
    
    @ViewBuilder
    private var formSection: some View {
        HStack {
            Text("Species")
                .font(.appTitle)
                .foregroundColor(.textPrimary)
            
            Spacer()
            
            Picker("Species", selection: $viewModel.species) {
                ForEach(PetSpecies.allCases) { species in
                    Label(species.rawValue, systemImage: species.icon)
                        .tag(species)
                }
            }
        }
        
        Divider()
        
        PrimaryTextField(
            title: "Name",
            placeholder: "Enter pet's name",
            text: $viewModel.name,
        )
        
        PrimaryTextField(
            title: "Breed (Optional)",
            placeholder: "Enter pet's breed",
            text: $viewModel.breed,
        )
        
        HStack {
            Text("Gender")
                .font(.appTitle)
                .foregroundColor(.textPrimary)
            
            Spacer()
            
            Picker("Gender", selection: $viewModel.gender) {
                ForEach(PetGender.allCases, id: \.self) {
                    Text($0.rawValue)
                }
            }
        }
        
        DatePicker(
            "Birthday",
            selection: $viewModel.birthDate,
            in: ...Date(),
            displayedComponents: .date
        )
        .font(.appTitle)
        .foregroundColor(.textPrimary)
        
        ErrorView(message: viewModel.errorMessage)
        
        Button("Add Pet") {
            Task {
                await viewModel.savePet()
            }
        }
        .buttonStyle(.primary(isLoading: viewModel.isLoading))
        .disabled(viewModel.isLoading)
    }
}

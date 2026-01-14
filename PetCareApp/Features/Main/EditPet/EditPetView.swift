//
//  EditPetView.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 08.01.26.
//


import SwiftUI

struct EditPetView: View {
    // MARK: - Properties
    
    @StateObject var viewModel: EditPetViewModel
    @Environment(\.dismiss) var dismiss
    
    let onSave: (Pet) -> Void
    
    // MARK: - Body
    
    var body: some View {
        ScreenStateContainer(
            state: viewModel.state,
            onRetry: {}
        ) {
            content
        }
    }
    
    // MARK: - Subviews
    
    private var content: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    
                    photoSection
                    
                    VStack(spacing: 20) {
                        basicInfoSection
                        bioSection
                    }
                    .padding(.horizontal, 24)
                    
                    Spacer(minLength: 40)
                }
                .padding(.vertical, 20)
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle("Edit Pet Info")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.textSecondary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            if let updatedPet = await viewModel.save() {
                                onSave(updatedPet)
                                dismiss()
                            }
                        }
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(.brandPrimary)
                    .disabled(viewModel.state == .loading || viewModel.name.isEmpty)
                }
            }
        }
    }
    
    private var photoSection: some View {
        VStack(spacing: 12) {
            PhotoPickerView(
                imageData: $viewModel.photoData,
                imageURL: viewModel.currentPhotoUrl,
                size: 140
            )
        }
        
    }
    
    private var basicInfoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeaderView(text: "Basic Info")
            
            PrimaryTextField(
                title: "Name",
                placeholder: "Pet's Name",
                text: $viewModel.name
            )
            
            PrimaryTextField(
                title: "Breed",
                placeholder: "Unknown Breed",
                text: $viewModel.breed
            )
            
            PrimaryTextField(
                title: "Color",
                placeholder: "e.g. Black & White",
                text: $viewModel.color
            )
            
            Divider()
            
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
            
            
            Divider()
        }
    }

    private var bioSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeaderView(text: "About")
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Bio")
                    .font(.appTitle)
                    .foregroundColor(.textPrimary)
                
                TextField("Write a short bio...", text: $viewModel.bio, axis: .vertical)
                    .lineLimit(4...8)
                    .padding()
                    .background(Color.surface)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.brandSecondary, lineWidth: 1)
                    )
            }
            
            Divider()
        }
    }
}

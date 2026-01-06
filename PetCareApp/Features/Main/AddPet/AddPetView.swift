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
        content
    }
    
    // MARK: - Subviews
    
    private var content: some View {
        ScrollView {
            VStack(spacing: 16) {
                photoPickerSection
                formSection
            }
            .padding(.horizontal, 24)
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
    
    private var photoPickerSection: some View {
        PhotosPicker(
            selection: $selectedItem,
            matching: .images,
            photoLibrary: .shared()
        ) {
            ZStack {
                if let data = viewModel.photoData,
                   let image = UIImage(data: data) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                } else {
                    Circle()
                        .fill(Color.brandSecondary.opacity(0.15))
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: "camera.fill")
                        .font(.title)
                        .foregroundColor(.brandSecondary)
                }
            }
        }
        .onChange(of: selectedItem) { _, item in
            Task {
                if let data = try? await item?.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data),
                   let compressedData = uiImage.jpegData(compressionQuality: 0.6) {
                    viewModel.photoData = compressedData
                }
            }
        }
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
        
        HStack {
            Text("Weight (kg)")
                .font(.appTitle)
                .foregroundColor(.textPrimary)
            
            Spacer()
            
            TextField("0.0", text: $viewModel.weight)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
        }
        
        ErrorView(message: viewModel.errorMessage)
        
        PrimaryButton(
            title: "Add Pet",
            isLoading: viewModel.isLoading
        ) {
            Task {
                await viewModel.savePet()
            }
        }
    }
}

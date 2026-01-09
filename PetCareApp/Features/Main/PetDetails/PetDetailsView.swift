//
//  PetDetailsView.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 03.01.26.
//

import SwiftUI

struct PetDetailsView: View {
    // MARK: - Properties
    
    @StateObject var viewModel: PetDetailsViewModel
    @Environment(\.navigate) var navigate
    @Environment(\.dismiss) var dismiss
    
    let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    // MARK: - Body
    
    var body: some View {
        ScreenStateContainer(
            state: viewModel.state,
            onRetry: { await viewModel.refresh() }
        ) {
            content
        }
        .navigationBarHidden(false)
        .task { await viewModel.refresh() }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) { toolbar }
        }
        .alert(item: $viewModel.alert) { $0.toAlert() }
    }
    
    // MARK: - Subviews
    
    private var content: some View {
        ScrollView {
            VStack(spacing: 0) {
                headerSection
                
                VStack(spacing: 24) {
                    
                    nameCard
                        .offset(y: -40)
                        .padding(.bottom, -40)
                    
                    aboutSection
                    
                    statusSection
                    
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 24)
            }
        }
        .ignoresSafeArea(edges: .top)
    }
    
    private var toolbar: some View {
        Menu {
            Button {
                navigate(
                    .editPet(
                        pet: viewModel.pet,
                        onSave: { updatedPet in
                            viewModel.applyUpdatedPet(updatedPet)
                        }
                    )
                )
            } label: {
                Label("Edit", systemImage: "pencil")
            }
            
            Button(role: .destructive) {
                viewModel.deleteTapped {
                    dismiss()
                }
            } label: {
                Label("Delete", systemImage: "trash")
            }
            
        } label: {
            Image(systemName: "ellipsis.circle.fill")
                .font(.appButton)
        }
    }
    
    private var headerSection: some View {
        ZStack(alignment: .bottom) {
            ImageView(
                urlString: viewModel.pet.photoUrl,
                contentMode: .fill
            )
            .frame(maxWidth: .infinity, minHeight: 350)
            .clipped()
        }
    }
    
    private var nameCard: some View {
        Group {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.pet.name)
                        .font(.appDisplay)
                        .foregroundColor(Color(viewModel.pet.genderColor))
                    
                    Text(viewModel.pet.displayBreed)
                        .font(.appBody)
                        .foregroundColor(.textSecondary)
                }
                
                Spacer()
                
                Text(viewModel.pet.displayGenderSymbol)
                    .font(.appHeader)
                    .foregroundColor(.white)
                    .padding(10)
                    .background(Color(viewModel.pet.genderColor))
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            .shadowCard()
        }
    }
    
    private var aboutSection: some View {
        Group {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "pawprint")
                    Text("About \(viewModel.pet.name)")
                        .font(.appHeader)
                }
                .foregroundColor(.textPrimary)
                
                LazyVGrid(columns: columns, spacing: 12) {
                    StatBubble(label: "Age", value: viewModel.pet.ageFormatted)
                    StatBubble(label: "Weight", value: viewModel.pet.displayWeight)
                    StatBubble(label: "Height", value: viewModel.pet.displayHeight)
                    StatBubble(label: "Color", value: viewModel.pet.displayColor)
                }
                
                Divider()
                
                Text(viewModel.pet.displayBio)
                    .italic(viewModel.pet.bio == "" || viewModel.pet.bio == nil)
            }
        }
    }
    
    private var statusSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "heart.text.square")
                Text("\(viewModel.pet.name)'s Status")
                    .font(.appHeader)
            }
            .foregroundColor(.textPrimary)
            
            VStack(spacing: 12) {
                StatusRow(
                    icon: "heart.circle.fill",
                    color: .red,
                    title: "Health",
                    status: "Abnormal",
                    time: "Last Vaccinated (2mon Ago)",
                    actionTitle: "Contact Vet",
                    actionColor: .red
                )
                
                StatusRow(
                    icon: "fork.knife",
                    color: .green,
                    title: "Food",
                    status: "Hungry",
                    time: "Last Fed (1h Ago)",
                    actionTitle: "Check Food",
                    actionColor: .green
                )
                
                StatusRow(
                    icon: "face.smiling.fill",
                    color: .orange,
                    title: "Mood",
                    status: "Happy",
                    time: "Walking (Now)",
                    actionTitle: "Whistle",
                    actionColor: .orange
                )
            }
        }
    }
}

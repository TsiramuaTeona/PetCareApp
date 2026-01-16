//
//  HomeView.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 03.01.26.
//


import SwiftUI

struct HomeView: View {
    // MARK: - Properties
    
    @StateObject var viewModel: HomeViewModel
    @Environment(\.navigate) private var navigate
    
    // MARK: - Body
    
    var body: some View {
        ScreenStateContainer(
            state: viewModel.state,
            onRetry: {
                await viewModel.loadData()
            }
        ) {
            content
        }
        .navigationTitle("Home")
        .toolbar(.hidden, for: .navigationBar)
        .task { await viewModel.loadData() }
    }
    
    // MARK: - Subviews
    
    private var content: some View {
        VStack(spacing: 0) {
            header
            
            if viewModel.household == nil {
                EmptyHouseholdView(
                    userName: viewModel.user?.fullName ?? "Friend",
                    action: {
                        navigate(.selectTab(.profile))
                    }
                )
            } else {
                dashboard
            }
        }
    }
    
    private var header: some View {
        HStack {
            HeaderView()
            
            Spacer()
            
            Button("", systemImage: "bell.fill") {
                navigate(.remindersList(items: viewModel.upcomingReminders))
            }
            .font(.appButton)
            .foregroundColor(.brandSecondary)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
    }
    
    private var dashboard: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                petsHeader
                
                petsList
                
                FunFactCard(fact: viewModel.dailyFact) {
                    withAnimation {
                        viewModel.refreshFact()
                    }
                }
                .padding(.horizontal, 24)
                
                upcomingSection
                
                Spacer(minLength: 40)
            }
            .padding(.top, 8)
        }
    }
    
    private var petsHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Label(viewModel.household?.name ?? "Home", systemImage: "house.fill")
                    .font(.appTitle)
                    .foregroundColor(.textSecondary)
                
                Text("My Pets")
                    .font(.appDisplay)
            }
            
            Spacer()
            
            let householdId = viewModel.household?.id ?? ""
            
            Button {
                guard !householdId.isEmpty else { return }
                navigate(.addPet(householdId: householdId))
            } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.appDisplay)
                    .foregroundColor(householdId.isEmpty ? .textSecondary : .brandPrimary)
            }
            .disabled(householdId.isEmpty)
        }
        .padding(.horizontal, 24)
    }
    
    private var petsList: some View {
        Group {
            if viewModel.pets.isEmpty {
                Text("No pets yet. Tap ⊕ to add one!")
                    .foregroundColor(.textSecondary)
                    .font(.appBody)
                    .padding(24)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 16) {
                        ForEach(viewModel.pets) { pet in
                            PetCard(pet: pet)
                                .onTapGesture {
                                    navigate(.petDetails(pet: pet))
                                }
                        }
                    }
                    .padding(24)
                }
            }
        }
    }
    
    private var upcomingSection: some View {
        Group {
            if !viewModel.upcomingReminders.isEmpty {
                VStack(alignment: .leading, spacing: 24) {
                    HStack {
                        Text("Upcoming")
                            .font(.appHeader)
                            .foregroundColor(.brandSecondary)
                        
                        Spacer()
                        
                        Button {
                            navigate(.remindersList(items: viewModel.upcomingReminders))
                        } label: {
                            Text("See All")
                                .font(.appBody)
                                .foregroundColor(.brandPrimary)
                        }
                    }
                    
                    VStack(spacing: 16) {
                        ForEach(viewModel.upcomingReminders.prefix(3)) { item in
                            ReminderCard(item: item)
                                .onTapGesture {
                                    navigate(.logDetails(petId: item.petId, petName: item.petName, log: item.log))
                                }
                        }
                    }
                }
                .padding(24)
            }
        }
    }
}

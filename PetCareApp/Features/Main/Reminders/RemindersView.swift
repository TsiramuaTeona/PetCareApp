//
//  RemindersView.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 13.01.26.
//


import SwiftUI

struct RemindersView: View {
    // MARK: - Properties
    
    @StateObject var viewModel: RemindersViewModel
    @Environment(\.navigate) var navigate
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 0) {
            
            filterBar
            
            ZStack {
                if viewModel.isLoading {
                    LoadingView()
                } else {
                    remindersList
                }
            }
        }
        .background(.mainBackground)
        .navigationBarHidden(false)
        .navigationTitle("Reminders")
    }
    
    // MARK: - Subviews
    
    private var filterBar: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    
                    CategoryFilterPill(
                        title: "All",
                        icon: "tray.full",
                        isSelected: viewModel.selectedCategory == nil,
                        color: .brandPrimary
                    ) {
                        withAnimation(.spring()) {
                            viewModel.selectCategory(nil)
                            proxy.scrollTo("all", anchor: .center)
                        }
                    }
                    .id("all")
                    
                    ForEach(viewModel.categories, id: \.self) { category in
                        CategoryFilterPill(
                            title: category.rawValue,
                            icon: category.icon,
                            isSelected: viewModel.selectedCategory == category,
                            color: category.color
                        ) {
                            withAnimation(.spring()) {
                                viewModel.selectCategory(category)
                                proxy.scrollTo(category, anchor: .center)
                            }
                        }
                        .id(category)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
            }
        }
    }
    
    private var remindersList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                if viewModel.filteredReminders.isEmpty {
                    emptyState
                } else {
                    ForEach(viewModel.filteredReminders) { item in
                        ReminderCard(item: item)
                            .onTapGesture {
                                navigate(
                                    .logDetails(petId: item.petId, petName: item.petName, log: item.log)
                                )
                            }
                    }
                }
            }
            .padding(24)
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 12) {
            Spacer()
                .frame(height: 250)
            
            Image(systemName: "magnifyingglass")
                .font(.system(size: 40))
                .foregroundColor(.brandSecondary.opacity(0.5))
            
            Text("No reminders found")
                .font(.appBody)
                .foregroundColor(.brandSecondary)
            
            Spacer()
        }
    }
}

//
//  CategorySection.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 12.01.26.
//


import SwiftUI

struct CategorySection: View {
    // MARK: - Properties
    
    @ObservedObject var viewModel: AddHealthLogViewModel
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeaderView(text: "General")
            
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(LogCategory.allCases) { category in
                            CategoryChip(
                                category: category,
                                isSelected: viewModel.category == category,
                                onTap: {
                                    withAnimation {
                                        viewModel.category = category
                                        viewModel.errorMessage = nil
                                        proxy.scrollTo(category, anchor: .center)
                                    }
                                }
                            )
                            .id(category)
                        }
                    }
                    .padding(.horizontal, 24)
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation {
                            proxy.scrollTo(viewModel.category, anchor: .center)
                        }
                    }
                }
            }
            .padding(.horizontal, -24)
            
            HStack {
                Text(
                    viewModel.isMedication
                    ? "Start Date"
                    : (viewModel.isHistoryLog ? "Date" : "Scheduled Date")
                )
                .font(.appTitle)
                .foregroundColor(.textPrimary)
                
                Spacer()
                
                DatePicker(
                    "",
                    selection: $viewModel.actionDate,
                    in: viewModel.isWeight ? Date.distantPast...Date() : Date.distantPast...Date.distantFuture,
                    displayedComponents: viewModel.isMedication ? [.date, .hourAndMinute] : [.date]
                )
                .labelsHidden()
            }
            .borderedSection()
        }
    }
}

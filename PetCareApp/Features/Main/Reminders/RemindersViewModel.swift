//
//  RemindersViewModel.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 13.01.26.
//


import Foundation
import Combine


final class RemindersViewModel: ObservableObject {
    // MARK: - Properties
    
    @Published var filteredReminders: [ReminderItem] = []
    @Published var selectedCategory: LogCategory? = nil
    @Published var isLoading = false
    
    private let allReminders: [ReminderItem]
    
    var categories: [LogCategory] {
        LogCategory.allCases.filter {$0 != .weight}
    }
    
    // MARK: - Initializer
    
    init(reminders: [ReminderItem]) {
        self.allReminders = reminders
        self.filteredReminders = reminders
    }
    
    // MARK: - Methods
    
    func selectCategory(_ category: LogCategory?) {
        selectedCategory = category
        filterData()
    }
    
    private func filterData() {
        isLoading = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            if let category = self.selectedCategory {
                self.filteredReminders = self.allReminders.filter {
                    $0.log.category == category
                }
            } else {
                self.filteredReminders = self.allReminders
            }
            
            self.isLoading = false
        }
    }
}

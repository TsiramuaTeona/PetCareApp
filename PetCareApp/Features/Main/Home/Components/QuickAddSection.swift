//
//  QuickAddSection.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 20.01.26.
//

import SwiftUI

struct QuickAddSection: View {

    // MARK: - Properties

    let pets: [Pet]
    let selectedPet: Pet?
    @Binding var selectedPetId: String

    var onActionTap: (_ petId: String, _ category: LogCategory) -> Void

    private let items: [LogCategory] = [.medication, .vaccine, .weight, .grooming]

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
    ]

    // MARK: - Body

    var body: some View {
        if !pets.isEmpty {
            content
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - Subviews

    private var content: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Add")
                .font(.appHeader)
                .foregroundColor(.brandSecondary)

            petPicker

            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(items, id: \.self) { category in
                    QuickAddCard(category: category) {
                        if let id = selectedPet?.id {
                            onActionTap(id, category)
                        }
                    }
                }
            }
        }
    }

    private var petPicker: some View {
        HStack {
            Text("Choose a pet")
                .font(.appBody)
                .foregroundColor(.textSecondary)

            Spacer()

            Picker("Choose a pet", selection: $selectedPetId) {
                ForEach(pets) { pet in
                    Text(pet.name).tag(pet.id ?? "")
                }
            }
            .background(.brandPrimary.opacity(0.1))
            .cornerRadius(10)
        }
    }
}

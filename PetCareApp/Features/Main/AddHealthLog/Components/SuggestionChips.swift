//
//  SuggestionChips.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 12.01.26.
//


import SwiftUI

struct SuggestionChips: View {
    // MARK: - Properties
    
    let suggestions: [String]
    let onSelect: (String) -> Void
    
    // MARK: - Body
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(suggestions, id: \.self) { suggestion in
                    Button(action: { onSelect(suggestion) }) {
                        Text(suggestion)
                            .font(.appCaption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(.brandPrimary.opacity(0.1))
                            .foregroundColor(.brandPrimary)
                            .cornerRadius(20)
                    }
                }
            }
        }
    }
}

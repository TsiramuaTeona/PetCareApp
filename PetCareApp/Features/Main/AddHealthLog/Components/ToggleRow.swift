//
//  ToggleRow.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 12.01.26.
//


import SwiftUI

struct ToggleRow: View {
    // MARK: - Properties
    
    let title: String
    @Binding var isOn: Bool
    
    // MARK: - Body
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.textPrimary)
                .font(.appTitle)
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(.brandPrimary)
        }
        .borderedSection()
    }
}

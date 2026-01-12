//
//  SectionHeaderView.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 12.01.26.
//




import SwiftUI

struct SectionHeaderView: View {
    // MARK: - Properties
    
    let text: String
    
    // MARK: - Body
    
    var body: some View {
        Text(text)
            .font(.headline)
            .foregroundColor(.brandSecondary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
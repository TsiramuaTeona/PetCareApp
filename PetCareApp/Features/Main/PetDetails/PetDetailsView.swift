//
//  PetDetailsView.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 03.01.26.
//


import SwiftUI

struct PetDetailsView: View {
    // MARK: - Properties
    
    let petId: String
    
    // MARK: - Body
    var body: some View {
        VStack {
            Text("Pet Details for ID: \(petId)")
                .font(.largeTitle)
                .padding()
        }
    }
}

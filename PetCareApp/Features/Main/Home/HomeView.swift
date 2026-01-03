//
//  HomeView.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 03.01.26.
//


import SwiftUI

struct HomeView: View {
    // MARK: - Properties
    @Environment(\.navigate) private var navigate
    
    // MARK: - Body
    
    var body: some View {
        VStack {
            Button("Go to Pet Details") {
                navigate(.petDetails(petId: "123"))
            }
            
            Button("Add Vaccine") {
                navigate(.scanner { code in
                    print("Scanned code: \(code)")
                })
            }
        }
    }
}

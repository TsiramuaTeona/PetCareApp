//
//  ShopView.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 03.01.26.
//


import SwiftUI

struct ShopView: View {
    // MARK: - Properties
    @Environment(\.navigate) private var navigate
    
    // MARK: - Body
    var body: some View {
        VStack {
            
            Text("Shop View")
                .font(.largeTitle)
                .padding()
        }
    }
}

//
//  View+Extensions.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 06.01.26.
//


import SwiftUI

extension View {
    func shadowCard() -> some View {
        self
            .padding()
            .background(.surface)
            .cornerRadius(10)
            .shadow(color: .textPrimary.opacity(0.08), radius: 10, x: 0, y: 5)
    }
}

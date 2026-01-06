//
//  HeaderView.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 06.01.26.
//


import SwiftUI

struct HeaderView: View {
    var body: some View {
        HStack(alignment: .center) {
            Image("AppLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 32, height: 32)
            
            HStack(spacing: 0) {
                Text("Pet")
                    .font(.appHeader)
                    .foregroundColor(.brandPrimary)
                
                Text("Care")
                    .font(.appHeader)
                    .foregroundColor(.brandSecondary)
            }
            
            Spacer()
        }
    }
}

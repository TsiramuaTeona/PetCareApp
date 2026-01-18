//
//  ScheduleRow.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 13.01.26.
//

import SwiftUI

struct ScheduleRow: View {
    // MARK: - Properties
    
    let label: String
    let value: String
    
    // MARK: - Body
    
    var body: some View {
        HStack {
            Text(label)
                .font(.appBody)
                .foregroundColor(.textSecondary)
            
            Spacer()
            
            Text(value)
                .font(.appBody)
                .foregroundColor(.textPrimary)
                .multilineTextAlignment(.trailing)
        }
    }
}

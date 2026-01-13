//
//  ReminderItem.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 10.01.26.
//


import Foundation

struct ReminderItem: Identifiable, Equatable {
    let id = UUID()
    let petId: String
    let petName: String
    let petPhoto: String?
    let log: HealthLog
}

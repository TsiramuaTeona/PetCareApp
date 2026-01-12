//
//  ReminderItem.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 10.01.26.
//


import Foundation

struct ReminderItem: Identifiable {
    let id = UUID()
    let petName: String
    let petPhoto: String?
    let log: HealthLog
}

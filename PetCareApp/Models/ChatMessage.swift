//
//  ChatMessage.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 15.01.26.
//


import Foundation

struct ChatMessage: Identifiable, Equatable {
    enum Role {
        case user
        case assistant
        case system
    }
    
    let id = UUID()
    let role: Role
    let text: String
    let date: Date
}

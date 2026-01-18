//
//  ChatMessageProvider.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 15.01.26.
//

import Foundation

enum ChatMessageProvider {
    
    // MARK: - Greetings
    
    static func welcome() -> ChatMessage {
        .init(
            role: .assistant,
            text: """
            Hey 👋 I’m your pet-care helper.
            
            You can ask me things like:
            • “What vaccines are coming up?”
            • “Summarize Bella’s medication schedule”
            • “Show weight trends and what they might mean”
            
            I’ll use your pets’ health info when available 🐾
            """,
            date: Date()
        )
    }
    
    // MARK: - User
    
    static func user(_ text: String) -> ChatMessage {
        .init(role: .user, text: text, date: Date())
    }
    
    // MARK: - Assistant
    
    static func assistant(_ text: String) -> ChatMessage {
        .init(role: .assistant, text: text, date: Date())
    }
    
    static func emptyReplyFallback() -> ChatMessage {
        assistant("Hmm… I didn’t get a clear answer 🤔 Try asking in a different way?")
    }
    
    static func genericError() -> ChatMessage {
        assistant("Oops 😿 Something went wrong on my side. Please try again in a moment.")
    }
    
    static func systemWithPets(petNames: [String]) -> ChatMessage {
        let cleaned = petNames
            .map { $0.trimmed }
            .filter { !$0.isEmpty }
        
        if cleaned.isEmpty {
            return system("🐾 Pets are connected! Ask me about meds, vaccines, food, or weight trends.")
        }
        
        let shown = cleaned.prefix(4).joined(separator: ", ")
        let extra = cleaned.count > 4 ? " +\(cleaned.count - 4) more" : ""
        
        return system("🐾 I’ve got \(shown)\(extra) loaded. Ask me anything about their care ✨")
    }
    
    static func systemWithoutPets() -> ChatMessage {
        system("🤝 I’m your general pet-care assistant! Ask me about feeding, training, safety, or symptoms 🐶🐱")
    }
    
    // MARK: - Private
    
    private static func system(_ text: String) -> ChatMessage {
        .init(role: .system, text: text, date: Date())
    }
}

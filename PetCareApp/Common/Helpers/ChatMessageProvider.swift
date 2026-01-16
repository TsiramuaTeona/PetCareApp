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
            
            I’ll always use your pets’ health info when available 🐾
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
        assistant("Hmm… I didn’t get a clear answer. Want to try asking that another way?")
    }
    
    static func genericError() -> ChatMessage {
        assistant("Something went wrong on my side 😕 Please try again in a moment.")
    }
    
    // MARK: - System / Status
    
    static func syncingHousehold() -> ChatMessage {
        system("Syncing your household pets and health logs…")
    }
    
    static func householdUpdated(hasHousehold: Bool) -> ChatMessage {
        system(
            hasHousehold
            ? "Household updated. Refreshing pet profiles and health data…"
            : "No household selected — switching to general pet-care mode."
        )
    }
    
    static func contextLoaded(petCount: Int, petNames: [String]) -> ChatMessage {
        if petCount == 0 {
            return system(
                "No pets found yet 🐾 I can still help with general care, training, feeding, and safety."
            )
        }
        
        let names = petNames.prefix(4).joined(separator: ", ")
        let extra = petCount > 4 ? " +\(petCount - 4) more" : ""
        
        return system(
            "Ready! Loaded \(petCount) pet\(petCount > 1 ? "s" : ""): \(names)\(extra).\nAsk me about meds, vaccines, or weight trends."
        )
    }
    
    static func refreshingContext() -> ChatMessage {
        system("Refreshing pet info… 🐾")
    }
    
    static func fallbackContext() -> ChatMessage {
        system("I couldn’t load pet data right now — I’ll answer using general pet-care knowledge.")
    }
    
    // MARK: - Private
    
    private static func system(_ text: String) -> ChatMessage {
        .init(role: .system, text: text, date: Date())
    }
}

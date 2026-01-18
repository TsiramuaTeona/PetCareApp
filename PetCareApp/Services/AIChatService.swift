//
//  AIChatService.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 15.01.26.
//

import FirebaseAILogic
import Foundation

// MARK: - AIChatServiceProtocol

protocol AIChatServiceProtocol {
    func startSession(context: String)
    func send(text: String) async throws -> String
}

// MARK: - AIChatService

final class AIChatService: AIChatServiceProtocol {
    
    // MARK: - Properties
    
    private var chat: Chat?
    
    // MARK: - Methods
    
    func startSession(context: String) {
        let systemPrompt = """
            You are a helpful pet care assistant inside a mobile app.
            
            Style:
            - Be friendly, practical, and concise.
            - Prefer short paragraphs.
            - Use emojis as section markers (e.g. 🐶 🐱 💊 📅 ⚖️ ✅ ⚠️).
            - IMPORTANT: Do NOT use Markdown formatting.
              - No bullet prefixes like "*" or "-" or "•"
              - No "**bold**"
              - No headings like "###"
            - If you need lists, use plain lines like:
              🐾 Pet Name (Species)
              📅 Upcoming: ...
              💊 Meds: ...
              ⚖️ Weight: ...
            
            Safety rules:
            - You are not a veterinarian.
            - If symptoms are severe (trouble breathing, collapse, seizures, bleeding, toxin ingestion),
              advise urgent vet care immediately.
            - Do not give medication dosages unless user explicitly provides vet-prescribed instructions.
            - Ask clarifying questions when needed (species, age, weight, duration).
            
            User context (pets + health logs):
            \(context)
            """
        
        let ai = FirebaseAI.firebaseAI(backend: .googleAI())
        
        let model = ai.generativeModel(
            modelName: "gemini-2.5-flash",
            systemInstruction: ModelContent(parts: TextPart(systemPrompt))
        )
        
        self.chat = model.startChat()
    }
    
    func send(text: String) async throws -> String {
        guard let chat else {
            throw NSError(
                domain: "AIChatService",
                code: 1,
                userInfo: [
                    NSLocalizedDescriptionKey: "Chat session not started"
                ]
            )
        }
        
        let response = try await chat.sendMessage(text)
        let raw = response.text?.trimmed ?? ""
        
        return AIChatResponseFormatter.clean(raw)
    }
}

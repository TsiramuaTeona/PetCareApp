//
//  FunFactService.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 14.01.26.
//


import Foundation

struct FunFactService {
    
    // MARK: - Models
    
    private struct FactData: Codable {
        let facts: [String]
    }
    
    // MARK: - Properties
    
    private static var cachedFacts: [String] = []
    
    // MARK: - Methods
    
    static func getRandomFact() -> String {
        if !cachedFacts.isEmpty {
            return cachedFacts.randomElement() ?? "Pets are amazing!"
        }
        
        guard let url = Bundle.main.url(forResource: "PetFacts", withExtension: "json") else {
            return "Could not find PetFacts.json"
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decodedData = try JSONDecoder().decode(FactData.self, from: data)
            cachedFacts = decodedData.facts
            
            return cachedFacts.randomElement() ?? "Pets are amazing!"
        } catch {
            print("Error parsing PetFacts.json: \(error)")
            return "Did you know? Pets make life better!"
        }
    }
}

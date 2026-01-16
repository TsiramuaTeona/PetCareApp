//
//  String+Extensions.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 09.01.26.
//


import Foundation

extension String {
    var doubleValue: Double? {
        Double(replacingOccurrences(of: ",", with: "."))
    }
    
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var nilIfEmpty: String? {
        isEmpty ? nil : self
    }
    
    var isEmptyOrWhitespace: Bool {
        trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var normalize: String {
        trimmed
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            .lowercased()
    }
}

//
//  AIChatResponseFormatter.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 16.01.26.
//

import Foundation

enum AIChatResponseFormatter {
    
    static func clean(_ string: String) -> String {
        var text = string
        
        text = text.replacingOccurrences(of: "**", with: "")
        text = text.replacingOccurrences(of: "__", with: "")
        
        text = text.replacingOccurrences(
            of: #"(?m)^\s*[\*\-]\s+"#,
            with: "• ",
            options: .regularExpression
        )
        
        text = text.replacingOccurrences(
            of: #"\n{3,}"#,
            with: "\n\n",
            options: .regularExpression
        )
        
        text = text.replacingOccurrences(
            of: #"(?m)^\s*•\s+"#,
            with: "➜ ",
            options: .regularExpression
        )
        
        return text.trimmed
    }
}

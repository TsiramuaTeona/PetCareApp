//
//  FieldValidator.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 03.01.26.
//

import Foundation

enum FieldValidator {
    
    static func required(_ text: String) -> AuthError? {
        return text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .required : nil
    }

    static func email(_ text: String) -> AuthError? {
        if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return .required
        }
        
        let pattern = #"^\S+@\S+\.\S+$"#
        let isMatch = text.range(of: pattern, options: .regularExpression) != nil
        
        return isMatch ? nil : .invalidEmail
    }
    
    static func password(_ text: String) -> AuthError? {
        if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return .required
        }
        
        let pattern = #"(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9]).{8,}"#
        let isMatch = text.range(of: pattern, options: .regularExpression) != nil
        
        return isMatch ? nil : .weakPassword
    }
    
    static func confirmPassword(_ text: String, password: String) -> AuthError?
    {
        if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return .required
        }
        return text == password ? nil : .passwordsDontMatch
    }
}

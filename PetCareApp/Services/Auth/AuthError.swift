//
//  AuthError.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 03.01.26.
//

import Foundation

enum AuthError: LocalizedError {
    case required
    case invalidEmail
    case weakPassword
    case passwordsDontMatch
    case invalidCredential
    case userNotFound
    case emailAlreadyInUse
    case googleSignCancelled
    case unknown(String)
    
    var errorDescription: String? {
        switch self {
        case .required:
            return "This field is required"
        case .invalidEmail:
            return "Please enter a valid email address"
        case .weakPassword:
            return "Password must be at least 8 characters with uppercase, lowercase, and number"
        case .passwordsDontMatch:
            return "Passwords do not match"
        case .invalidCredential:
            return "Invalid email or password."
        case .userNotFound:
            return "No account found with this email."
        case .emailAlreadyInUse:
            return "This email is already registered."
        case .googleSignCancelled:
            return "Google sign-in was cancelled."
        case .unknown(let message):
            return message
        }
    }
}

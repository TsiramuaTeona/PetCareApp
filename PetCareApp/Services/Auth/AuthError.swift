//
//  AuthError.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 03.01.26.
//


import Foundation

enum AuthError: LocalizedError {
    case invalidEmail
    case weakPassword
    case wrongPassword
    case userNotFound
    case emailAlreadyInUse
    case unknown(String)
    case googleSignCancelled
    
    var errorDescription: String? {
        switch self {
        case .invalidEmail:
            return "Please enter a valid email address."
        case .weakPassword:
            return "Password is too weak. Please use at least 6 characters."
        case .wrongPassword:
            return "Incorrect password. Please try again."
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

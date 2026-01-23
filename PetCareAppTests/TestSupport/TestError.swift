//
//  TestError.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 23.01.26.
//


import Foundation

enum TestError: Error, Equatable, LocalizedError {
    case stubbed
    case message(String)
    
    var errorDescription: String? {
        switch self {
        case .stubbed:
            return "stubbed"
        case .message(let msg):
            return msg
        }
    }
}

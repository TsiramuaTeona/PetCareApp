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
    
    var nilIfEmpty: String? {
        isEmpty ? nil : self
    }
}

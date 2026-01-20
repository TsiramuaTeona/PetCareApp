//
//  UIFont+Extensions.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 20.01.26.
//

import UIKit

extension UIFont {
    static func rounded(ofSize size: CGFloat, weight: UIFont.Weight) -> UIFont {
        let systemFont = UIFont.systemFont(ofSize: size, weight: weight)
        if let descriptor = systemFont.fontDescriptor.withDesign(.rounded) {
            return UIFont(descriptor: descriptor, size: size)
        } else {
            return systemFont
        }
    }
}

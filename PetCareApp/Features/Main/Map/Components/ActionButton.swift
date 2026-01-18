//
//  ActionButton.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 07.01.26.
//

import UIKit

final class ActionButton: UIButton {
    
    // MARK: - Initializer
    
    init(title: String, image: String) {
        super.init(frame: .zero)
        configure(title: title, image: image)
        
        heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configuration
    
    private func configure(title: String, image: String) {
        var config = UIButton.Configuration.filled()
        config.title = title
        config.image = UIImage(systemName: image)
        config.imagePadding = 10
        config.cornerStyle = .large
        config.baseBackgroundColor = .mainBackground
        config.baseForegroundColor = .brandSecondary
        
        configuration = config
    }
}

//
//  TypingIndicatorCell.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 16.01.26.
//

import UIKit

final class TypingIndicatorCell: UITableViewCell {
    
    // MARK: - Properties
    
    static let reuseId = "TypingIndicatorCell"
    
    private let bubbleView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .brandPrimary.withAlphaComponent(0.1)
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        return view
    }()
    private let typingView = PawTypingIndicatorView(pawCount: 3, pawSize: 16)
    
    // MARK: - Initializers
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func prepareForReuse() {
        super.prepareForReuse()
        typingView.stop()
    }
    
    // MARK: - Methods
    
    func startAnimating() {
        typingView.start()
    }
    
    func stopAnimating() {
        typingView.stop()
    }
    
    private func setupView() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        contentView.addSubview(bubbleView)
        bubbleView.addSubview(typingView)
        
        NSLayoutConstraint.activate([
            bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            bubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            bubbleView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            bubbleView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -80),
            
            typingView.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 12),
            typingView.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -12),
            typingView.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 12),
            typingView.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -12)
        ])
    }
}

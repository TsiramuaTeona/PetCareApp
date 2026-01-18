//
//  ChatMessageCell.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 15.01.26.
//

import UIKit

final class ChatMessageCell: UITableViewCell {
    
    // MARK: - Properties
    
    static let reuseId = "ChatMessageCell"
    
    private let bubbleView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var leadingConstraint: NSLayoutConstraint!
    private var trailingConstraint: NSLayoutConstraint!
    
    // MARK: - Initializers
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    // MARK: - Methods
    
    private func setupView() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        contentView.addSubview(bubbleView)
        bubbleView.addSubview(messageLabel)
        
        leadingConstraint = bubbleView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24)
        trailingConstraint = bubbleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24)
        
        NSLayoutConstraint.activate([
            bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            bubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            bubbleView.widthAnchor.constraint(lessThanOrEqualTo: contentView.widthAnchor, multiplier: 0.78),
            
            messageLabel.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 10),
            messageLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -10),
            messageLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 12),
            messageLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -12),
            
            leadingConstraint,
            trailingConstraint
        ])
    }
    
    func configure(with message: ChatMessage) {
        messageLabel.text = message.text
        
        switch message.role {
        case .user:
            bubbleView.backgroundColor = .brandSecondary.withAlphaComponent(0.15)
            messageLabel.textColor = .textPrimary
            messageLabel.font = .systemFont(ofSize: 15)
            
            leadingConstraint.isActive = false
            trailingConstraint.isActive = true
            
        case .assistant:
            bubbleView.backgroundColor = .brandPrimary.withAlphaComponent(0.15)
            messageLabel.textColor = .textPrimary
            messageLabel.font = .systemFont(ofSize: 15)
            
            trailingConstraint.isActive = false
            leadingConstraint.isActive = true
            
        case .system:
            bubbleView.backgroundColor = .surface
            messageLabel.textColor = .textSecondary
            messageLabel.font = .italicSystemFont(ofSize: 12)
            
            trailingConstraint.isActive = false
            leadingConstraint.isActive = true
        }
    }
}

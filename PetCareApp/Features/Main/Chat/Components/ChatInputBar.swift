//
//  ChatInputBar.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 16.01.26.
//


import UIKit

final class ChatInputBar: UIView {
    
    // MARK: - Properties
    
    var onSend: ((String) -> Void)?
    
    private var textViewHeightConstraint: NSLayoutConstraint!
    
    private let minTextViewHeight: CGFloat = 44
    private let maxTextViewHeight: CGFloat = 110
    
    private let textView: UITextView = {
        let textView = UITextView()
        textView.font = .systemFont(ofSize: 16)
        textView.backgroundColor = .brandSecondary.withAlphaComponent(0.1)
        textView.layer.cornerRadius = 16
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 12)
        textView.isScrollEnabled = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    let sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "paperplane.fill"), for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 16)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Initializers
    
    init() {
        super.init(frame: .zero)
        
        setupView()
        setupAction()
        setupTextView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    
    private func setupView() {
        backgroundColor = .mainBackground
        translatesAutoresizingMaskIntoConstraints = false
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.06
        layer.shadowRadius = 10
        layer.shadowOffset = CGSize(width: 0, height: -3)
        
        addSubview(textView)
        addSubview(sendButton)
        
        textViewHeightConstraint = textView.heightAnchor.constraint(equalToConstant: minTextViewHeight)
        
        NSLayoutConstraint.activate([
            heightAnchor.constraint(greaterThanOrEqualToConstant: 56),
            
            textView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            textView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            textView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -10),
            textViewHeightConstraint,
            
            sendButton.leadingAnchor.constraint(equalTo: textView.trailingAnchor, constant: 10),
            sendButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
            sendButton.bottomAnchor.constraint(equalTo: textView.bottomAnchor, constant: -5),
            sendButton.widthAnchor.constraint(equalToConstant: 32)
        ])
    }
    
    private func setupTextView() {
        textView.delegate = self
        
        DispatchQueue.main.async { [weak self] in
            self?.updateTextViewHeight()
        }
    }
    
    // MARK: - Actions
    
    private func setupAction() {
        sendButton.addAction(UIAction { [weak self] _ in
            guard let self = self else { return }
            let text = self.textView.text.trimmed
            guard !text.isEmpty else { return }
            
            self.textView.text = ""
            self.updateTextViewHeight()
            self.onSend?(text)
        }, for: .touchUpInside)
    }
    
    // MARK: - Helpers
    
    private func updateTextViewHeight() {
        guard textView.bounds.width > 0 else { return }
        
        let size = CGSize(width: textView.bounds.width, height: .greatestFiniteMagnitude)
        let estimatedHeight = textView.sizeThatFits(size).height
        
        let clamped = min(max(estimatedHeight, minTextViewHeight), maxTextViewHeight)
        textViewHeightConstraint.constant = clamped
        
        textView.isScrollEnabled = estimatedHeight > maxTextViewHeight
        
        layoutIfNeeded()
    }
}

// MARK: - UITextViewDelegate

extension ChatInputBar: UITextViewDelegate {
    @objc func textViewDidChange(_ textView: UITextView) {
        updateTextViewHeight()
    }
}

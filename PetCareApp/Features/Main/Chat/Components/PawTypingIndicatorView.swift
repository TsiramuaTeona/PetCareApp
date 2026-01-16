//
//  PawTypingIndicatorView.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 16.01.26.
//


import UIKit

final class PawTypingIndicatorView: UIView {
    
    // MARK: - Properties
    
    private var isAnimating = false
    
    private let pawCount: Int
    private let pawSize: CGFloat
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .fill
        stack.spacing = 10
        stack.isLayoutMarginsRelativeArrangement = false
        return stack
    }()
    
    private var pawViews: [UIImageView] = []
    
    
    // MARK: - Initializers
    
    init(pawCount: Int = 3, pawSize: CGFloat = 18) {
        self.pawCount = max(1, pawCount)
        self.pawSize = pawSize
        super.init(frame: .zero)
        
        setupView()
        buildPaws()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    
    override var intrinsicContentSize: CGSize {
        let spacing = stackView.spacing
        let width = (CGFloat(pawCount) * pawSize) + (CGFloat(max(0, pawCount - 1)) * spacing)
        let height = pawSize
        return CGSize(width: width, height: height)
    }
    
    // MARK: - Methods
    
    func start() {
        guard !isAnimating else { return }
        isAnimating = true
        runLoopedAnimation()
    }
    
    func stop() {
        isAnimating = false
        pawViews.forEach { $0.layer.removeAllAnimations() }
        for (index, paw) in pawViews.enumerated() {
            paw.alpha = index == 0 ? 1.0 : 0.5
            paw.transform = .identity
        }
    }
    
    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        clipsToBounds = false
        
        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        setContentHuggingPriority(.required, for: .horizontal)
        setContentCompressionResistancePriority(.required, for: .horizontal)
    }
    
    private func buildPaws() {
        pawViews.removeAll()
        
        for index in 0..<pawCount {
            let paw = UIImageView(image: UIImage(systemName: "pawprint.fill"))
            paw.translatesAutoresizingMaskIntoConstraints = false
            paw.contentMode = .scaleAspectFit
            paw.tintColor = (index == 0) ? .brandPrimary : .brandSecondary.withAlphaComponent(0.7)
            paw.alpha = (index == 0) ? 1.0 : 0.45
            paw.transform = .identity
            
            NSLayoutConstraint.activate([
                paw.widthAnchor.constraint(equalToConstant: pawSize),
                paw.heightAnchor.constraint(equalToConstant: pawSize)
            ])
            
            stackView.addArrangedSubview(paw)
            pawViews.append(paw)
        }
        
        invalidateIntrinsicContentSize()
    }
    
    private func runLoopedAnimation() {
        guard isAnimating else { return }
        
        for (index, paw) in pawViews.enumerated() {
            let delay = Double(index) * 0.18
            
            UIView.animate(
                withDuration: 0.55,
                delay: delay,
                options: [.autoreverse, .repeat, .allowUserInteraction],
                animations: {
                    paw.alpha = 1.0
                    paw.transform = CGAffineTransform(scaleX: 1.12, y: 1.12)
                },
                completion: nil
            )
            
            UIView.animate(
                withDuration: 0.55,
                delay: delay,
                options: [.autoreverse, .repeat, .allowUserInteraction],
                animations: {
                    paw.tintColor = .brandPrimary
                },
                completion: nil
            )
        }
    }
}

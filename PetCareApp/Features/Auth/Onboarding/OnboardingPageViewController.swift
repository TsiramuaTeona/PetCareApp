//
//  OnboardingPageViewController.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 20.01.26.
//

import UIKit

final class OnboardingPageViewController: UIViewController {
    // MARK: - Properties
    
    private let titleText: String
    private let subtitleText: String
    private let systemImageName: String
    private let backgroundImageName: String?
    
    private var backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let cardView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 20
        view.layer.cornerCurve = .continuous
        view.clipsToBounds = true
        return view
    }()
    
    private let cardBlurView: UIVisualEffectView = {
        let visualEffect = UIVisualEffectView(effect: UIBlurEffect(style: .systemThinMaterial))
        visualEffect.translatesAutoresizingMaskIntoConstraints = false
        return visualEffect
    }()
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .brandPrimary
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = .rounded(ofSize: 22, weight: .bold)
        titleLabel.textColor = .brandPrimary
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        return titleLabel
    }()
    
    private let subtitleLabel: UILabel = {
        let subtitleLabel = UILabel()
        subtitleLabel.font = .systemFont(ofSize: 16, weight: .regular)
        subtitleLabel.textColor = .textPrimary
        subtitleLabel.numberOfLines = 0
        subtitleLabel.textAlignment = .center
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        return subtitleLabel
    }()

    // MARK: - Initializer
    
    init(
        titleText: String,
        subtitleText: String,
        systemImageName: String,
        backgroundImageName: String? = nil
    ) {
        self.titleText = titleText
        self.subtitleText = subtitleText
        self.systemImageName = systemImageName
        self.backgroundImageName = backgroundImageName
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .mainBackground
        
        imageView.image = UIImage(systemName: systemImageName)
        titleLabel.text = titleText
        subtitleLabel.text = subtitleText
        
        setupBackground()
        setupCardView()
    }
    
    // MARK: - Setup
    
    private func setupBackground() {
        guard let backgroundImageName,
              let image = UIImage(named: backgroundImageName)
        else { return }
        
        backgroundImageView.image = image
        view.addSubview(backgroundImageView)
        
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func setupCardView() {
        view.addSubview(cardView)
        cardView.addSubview(cardBlurView)
        cardView.addSubview(stackView)
        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(subtitleLabel)
        
        NSLayoutConstraint.activate([
            cardBlurView.topAnchor.constraint(equalTo: cardView.topAnchor),
            cardBlurView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor),
            cardBlurView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            cardBlurView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            
            cardView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            cardView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            cardView.topAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.topAnchor, constant: 80),
            
            stackView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 20),
            stackView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -200),
            stackView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
            
            imageView.heightAnchor.constraint(equalToConstant: 64),
            imageView.widthAnchor.constraint(equalToConstant: 64),
        ])
    }
}

extension OnboardingPageViewController {
    static func == (
        lhs: OnboardingPageViewController,
        rhs: OnboardingPageViewController
    ) -> Bool {
        lhs === rhs
    }
}

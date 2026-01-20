//
//  OnboardingViewController.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 20.01.26.
//

import UIKit

final class OnboardingViewController: UIViewController {
    // MARK: - Properties

    var onFinish: (() -> Void)?

    private let pages: [OnboardingPageViewController] = [
        .init(
            titleText: "Welcome to PetCare 🐾",
            subtitleText:
                "Create pet profiles, track health logs, and keep everything organized in one place - so you’re always on top of your pet’s wellbeing.",
            systemImageName: "pawprint.fill",
            backgroundImageName: "pet_1"
        ),
        .init(
            titleText: "Reminders that actually help",
            subtitleText:
                "Set medication times and due dates. PetCare will notify you for upcoming doses, vaccinations, and other important tasks - no more guessing.",
            systemImageName: "bell.badge.fill",
            backgroundImageName: "pet_2"
        ),
        .init(
            titleText: "Find a vet fast",
            subtitleText: "Open the map to see nearby veterinary clinics and get there quickly when you need urgent help.",
            systemImageName: "map.fill",
            backgroundImageName: "pet_3"
        ),
        .init(
            titleText: "Quick help from AI",
            subtitleText: "Ask the built-in assistant for quick guidance based on your pet’s information and symptoms - so you know what to do next.",
            systemImageName: "sparkles",
            backgroundImageName: "pet_4"
        ),
    ]

    private lazy var pageViewController: UIPageViewController = {
        let viewController = UIPageViewController(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal
        )
        viewController.dataSource = self
        viewController.delegate = self
        return viewController
    }()

    private let pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.currentPageIndicatorTintColor = .brandSecondary
        pageControl.pageIndicatorTintColor = .brandSecondary.withAlphaComponent(0.3)
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        return pageControl
    }()

    private let primaryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Next", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.backgroundColor = .brandPrimary
        button.setTitleColor(.systemBackground, for: .normal)
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 52).isActive = true
        return button
    }()

    private let skipButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Skip", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
        button.setTitleColor(.textSecondary, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private var currentIndex: Int = 0 {
        didSet {
            pageControl.currentPage = currentIndex
            let isLast = currentIndex == pages.count - 1
            primaryButton.setTitle(
                isLast ? "Get Started" : "Next",
                for: .normal
            )
            skipButton.isHidden = isLast
        }
    }
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .mainBackground

        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.didMove(toParent: self)

        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            pageViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            pageViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pageViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        pageControl.numberOfPages = pages.count

        pageViewController.setViewControllers(
            [pages[0]],
            direction: .forward,
            animated: false
        )
        
        currentIndex = 0

        layoutBottomControls()

        primaryButton.addTarget(
            self,
            action: #selector(didTapPrimary),
            for: .touchUpInside
        )
        
        skipButton.addTarget(
            self,
            action: #selector(didTapSkip),
            for: .touchUpInside
        )
    }

    // MARK: - Private Methods
    
    private func layoutBottomControls() {
        let bottomContainer = UIView()
        bottomContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bottomContainer)

        bottomContainer.addSubview(pageControl)
        bottomContainer.addSubview(primaryButton)
        bottomContainer.addSubview(skipButton)

        NSLayoutConstraint.activate([
            bottomContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            bottomContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            bottomContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),

            pageControl.topAnchor.constraint(equalTo: bottomContainer.topAnchor),
            pageControl.centerXAnchor.constraint(equalTo: bottomContainer.centerXAnchor),

            primaryButton.topAnchor.constraint(equalTo: pageControl.bottomAnchor, constant: 16),
            primaryButton.leadingAnchor.constraint(equalTo: bottomContainer.leadingAnchor),
            primaryButton.trailingAnchor.constraint(equalTo: bottomContainer.trailingAnchor),

            skipButton.topAnchor.constraint(equalTo: primaryButton.bottomAnchor, constant: 12),
            skipButton.centerXAnchor.constraint(equalTo: bottomContainer.centerXAnchor),
            skipButton.bottomAnchor.constraint(equalTo: bottomContainer.bottomAnchor),
        ])
    }
    
    // MARK: - Actions

    private func playFinishConfetti() {
        view.layoutIfNeeded()
        
        let emitter = CAEmitterLayer()
        emitter.emitterPosition = CGPoint(x: view.bounds.midX, y: -20)
        emitter.emitterShape = .line
        emitter.emitterSize = CGSize(width: view.bounds.width, height: 1)
        emitter.renderMode = .additive
        
        let cell = CAEmitterCell()
        cell.contents = tintedSymbolCGImage(
            name: "pawprint.fill",
            pointSize: 40,
            color: .brandPrimary
        )
        
        cell.birthRate = 10
        cell.lifetime = 5.0
        cell.lifetimeRange = 1.5
        
        cell.velocity = 110
        cell.velocityRange = 60
        
        cell.emissionLongitude = .pi
        cell.emissionRange = .pi / 8
        cell.xAcceleration = 10
        cell.yAcceleration = 30
        
        cell.scale = 0.22
        cell.scaleRange = 0.10
        
        cell.spin = 1.2
        cell.spinRange = 2.0
        cell.alphaSpeed = -0.25
        
        emitter.emitterCells = [cell]
        view.layer.addSublayer(emitter)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            emitter.birthRate = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 8.0) {
            emitter.removeFromSuperlayer()
        }
    }

    private func tintedSymbolCGImage(
        name: String,
        pointSize: CGFloat,
        color: UIColor
    ) -> CGImage? {
        let config = UIImage.SymbolConfiguration(pointSize: pointSize, weight: .regular)
        guard let img = UIImage(systemName: name, withConfiguration: config)?
            .withTintColor(color, renderingMode: .alwaysOriginal)
        else { return nil }
        
        let renderer = UIGraphicsImageRenderer(size: img.size)
        let rendered = renderer.image { _ in
            img.draw(in: CGRect(origin: .zero, size: img.size))
        }
        return rendered.cgImage
    }

    @objc private func didTapPrimary() {
        let next = currentIndex + 1
        if next >= pages.count {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            playFinishConfetti()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { [weak self] in
                self?.onFinish?()
            }
            return
        }

        UISelectionFeedbackGenerator().selectionChanged()
        pageViewController.setViewControllers(
            [pages[next]],
            direction: .forward,
            animated: true
        )
        currentIndex = next
    }

    @objc private func didTapSkip() {
        onFinish?()
    }
}

extension OnboardingViewController: UIPageViewControllerDataSource,
    UIPageViewControllerDelegate
{

    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        guard
            let vc = viewController as? OnboardingPageViewController,
            let index = pages.firstIndex(of: vc),
            index > 0
        else { return nil }
        return pages[index - 1]
    }

    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        guard
            let viewController = viewController as? OnboardingPageViewController,
            let index = pages.firstIndex(of: viewController),
            index < pages.count - 1
        else { return nil }
        return pages[index + 1]
    }

    func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool
    ) {
        guard completed,
            let vc = pageViewController.viewControllers?.first
                as? OnboardingPageViewController,
            let index = pages.firstIndex(of: vc)
        else { return }
        currentIndex = index
    }
}

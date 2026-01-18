//
//  VetActionSheetViewController.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 06.01.26.
//

import MapKit
import UIKit

final class VetActionSheetViewController: UIViewController {
    // MARK: - Properties
    
    private let vet: VetAnnotation
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .semibold)
        label.textColor = .brandPrimary
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.textColor = .textSecondary
        label.numberOfLines = 2
        return label
    }()
    
    private let directionsButton = ActionButton(
        title: "Directions",
        image: "location.fill"
    )
    
    private let callButton = ActionButton(
        title: "Call",
        image: "phone.fill"
    )
    
    private let websiteButton = ActionButton(
        title: "Website",
        image: "safari.fill"
    )

    // MARK: - Initializer
    
    init(vet: VetAnnotation) {
        self.vet = vet
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        setupUI()
        configureSheet()
        configureActions()
        setupDismissGesture()
    }
    
    private func setupUI() {
        view.addSubview(stackView)
        
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(subtitleLabel)
        stackView.addArrangedSubview(directionsButton)
        stackView.addArrangedSubview(callButton)
        stackView.addArrangedSubview(websiteButton)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 24),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: -24)
        ])
        
        titleLabel.text = vet.title
        subtitleLabel.text = vet.subtitle
    }
    
    private func configureActions() {
        directionsButton.addTarget(self, action: #selector(directionsTapped), for: .touchUpInside)
        callButton.addTarget(self, action: #selector(callTapped), for: .touchUpInside)
        websiteButton.addTarget(self, action: #selector(websiteTapped), for: .touchUpInside)
    }
    
    func configureSheet() {
        guard let sheet = sheetPresentationController else { return }
        
        sheet.detents = [.medium()]
        
        sheet.prefersGrabberVisible = true
        sheet.preferredCornerRadius = 40
        sheet.largestUndimmedDetentIdentifier = .medium
        
        isModalInPresentation = false
        
        sheet.prefersEdgeAttachedInCompactHeight = true
        sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
    }
    
    private func setupDismissGesture() {
        if let presentingView = presentingViewController?.view {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissSheet))
            tapGesture.cancelsTouchesInView = false
            presentingView.addGestureRecognizer(tapGesture)
        }
    }
    
    // MARK: - Actions
    
    @objc func directionsTapped() {
        MKMapItem.openMaps(
            with: [vet.mapItem],
            launchOptions: [
                MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
            ]
        )
    }
    
    @objc func callTapped() {
        guard let phone = vet.phoneNumber,
              let url = URL(string: "tel://\(phone)") else { return }
        UIApplication.shared.open(url)
    }
    
    @objc func websiteTapped() {
        guard let website = vet.website else { return }
        UIApplication.shared.open(website)
    }
    
    @objc private func dismissSheet() {
        dismiss(animated: true)
    }
}

//
//  Screen4ViewController.swift
//  Memora
//
//  Created by Assistant on 05/11/25.
//

import UIKit

class Screen4ViewController: UIViewController {
    let imageView = UIImageView()
    let titleLabel = UILabel()
    let continueButton = UIButton(type: .system)
    let bottomTextLabel: UILabel? = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.hidesBackButton = false

        setupViews()
        applyConstraints()
    }

    private func setupViews() {
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)

        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)

        continueButton.setTitle("Continue", for: .normal)
        continueButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        continueButton.translatesAutoresizingMaskIntoConstraints = false
        continueButton.addTarget(self, action: #selector(continueTapped(_:)), for: .touchUpInside)
        view.addSubview(continueButton)

        if let bottomTextLabel = bottomTextLabel {
            bottomTextLabel.font = UIFont.systemFont(ofSize: 14)
            bottomTextLabel.textAlignment = .center
            bottomTextLabel.numberOfLines = 0
            bottomTextLabel.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(bottomTextLabel)
        }
    }

    private func applyConstraints() {
        let guide = view.safeAreaLayoutGuide
        var constraints: [NSLayoutConstraint] = []

        // Image at top
        constraints += [
            imageView.topAnchor.constraint(equalTo: guide.topAnchor, constant: 24),
            imageView.centerXAnchor.constraint(equalTo: guide.centerXAnchor),
            imageView.leadingAnchor.constraint(greaterThanOrEqualTo: guide.leadingAnchor, constant: 20),
            imageView.trailingAnchor.constraint(lessThanOrEqualTo: guide.trailingAnchor, constant: -20)
        ]

        // Title centered below image
        constraints += [
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 16),
            titleLabel.centerXAnchor.constraint(equalTo: guide.centerXAnchor),
            titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: guide.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: guide.trailingAnchor, constant: -24)
        ]

        // Continue button anchored to safe area bottom
        constraints += [
            continueButton.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 24),
            continueButton.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -24),
            continueButton.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -24),
            continueButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 44)
        ]

        // Bottom text above continue button
        if let bottomTextLabel = bottomTextLabel {
            constraints += [
                bottomTextLabel.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 24),
                bottomTextLabel.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -24),
                bottomTextLabel.bottomAnchor.constraint(equalTo: continueButton.topAnchor, constant: -12)
            ]
        }

        // Ensure title stays above continue button on compact heights
        constraints += [
            titleLabel.bottomAnchor.constraint(lessThanOrEqualTo: continueButton.topAnchor, constant: -24)
        ]

        NSLayoutConstraint.activate(constraints)
    }

    // MARK: - Actions
    @objc private func continueTapped(_ sender: UIButton) {
        let vc = Screen5ViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}

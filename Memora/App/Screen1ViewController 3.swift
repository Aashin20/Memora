//
//  Screen1ViewController.swift
//  Memora
//
//  Created by Assistant on 05/11/25.
//

import UIKit

class Screen1ViewController: UIViewController {
    // IBOutlets connected from storyboard
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var bottomTextLabel: UILabel? // optional

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        applyConstraints()
    }

    private func applyConstraints() {
        [imageView, titleLabel, continueButton, skipButton, bottomTextLabel].forEach { $0?.translatesAutoresizingMaskIntoConstraints = false }
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

        // Skip button above continue button (centered)
        constraints += [
            skipButton.bottomAnchor.constraint(equalTo: continueButton.topAnchor, constant: -12),
            skipButton.centerXAnchor.constraint(equalTo: guide.centerXAnchor)
        ]

        // Ensure title stays above buttons on compact heights
        constraints += [
            titleLabel.bottomAnchor.constraint(lessThanOrEqualTo: skipButton.topAnchor, constant: -24)
        ]

        NSLayoutConstraint.activate(constraints)
    }

    // MARK: - Actions
    @IBAction func continueTapped(_ sender: UIButton) {
        // Push Screen2ViewController
        let vc = Screen2ViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

    @IBAction func skipTapped(_ sender: UIButton) {
        // Push Screen5ViewController
        let vc = Screen5ViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}

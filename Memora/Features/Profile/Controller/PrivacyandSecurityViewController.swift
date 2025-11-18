//
//  PrivacyandSecurityViewController.swift
//  Memora
//
//  Created by user@3 on 13/11/25.
//

import UIKit

class PrivacyandSecurityViewController: UIViewController {

    // MARK: - Outlets

    @IBOutlet weak var phoneAndEmailView: UIView!
    @IBOutlet weak var changePasswordView: UIView!

    // Phone
    @IBOutlet weak var phoneButton: UIButton!
    @IBOutlet weak var phoneChevronButton: UIButton!

    // Email
    @IBOutlet weak var emailButton: UIButton!
    @IBOutlet weak var emailChevronButton: UIButton!

    // Change Password
    @IBOutlet weak var changePasswordButton: UIButton!
    @IBOutlet weak var changePasswordChevronButton: UIButton!

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        title = "Privacy and Security"
        view.backgroundColor = UIColor.systemGray6
    }

    // MARK: - UI Setup
    private func setupUI() {
        // Rounded corner container views
        phoneAndEmailView.layer.cornerRadius = 12
        phoneAndEmailView.layer.masksToBounds = true
        phoneAndEmailView.backgroundColor = .white

        changePasswordView.layer.cornerRadius = 12
        changePasswordView.layer.masksToBounds = true
        changePasswordView.backgroundColor = .white
    }

    // MARK: - Actions

    @IBAction func phoneButtonTapped(_ sender: UIButton) {
        print("Phone section tapped")
        // Navigate or perform action here
    }

    @IBAction func phoneChevronTapped(_ sender: UIButton) {
        print("Chevron (Phone) tapped")
    }

    @IBAction func emailButtonTapped(_ sender: UIButton) {
        print("Email section tapped")
    }

    @IBAction func emailChevronTapped(_ sender: UIButton) {
        print("Chevron (Email) tapped")
    }

    @IBAction func changePasswordButtonTapped(_ sender: UIButton) {
        print("Change Password section tapped")
    }

    @IBAction func changePasswordChevronTapped(_ sender: UIButton) {
        print("Chevron (Change Password) tapped")
    }
}

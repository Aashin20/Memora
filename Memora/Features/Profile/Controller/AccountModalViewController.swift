//
//  AccountModalViewController.swift
//  Memora
//

import UIKit

class AccountModalViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var nameCardView: UIView!
    @IBOutlet weak var notificationView: UIView!
    @IBOutlet weak var inviteView: UIView!
    @IBOutlet weak var helpView: UIView!
    @IBOutlet weak var logoutView: UIView!
    @IBOutlet weak var personalPrivacyContainerView: UIView!

    @IBOutlet weak var personalInfoButton: UIButton!
    @IBOutlet weak var privacyButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavBar()
        setupUI()
        setupActions()
    }

    //  Proper navigation bar title + close button
    private func setupNavBar() {
        title = "Account"
        navigationController?.navigationBar.prefersLargeTitles = false
        
        let closeButton = UIBarButtonItem(
            image: UIImage(systemName: "xmark"),
            style: .plain,
            target: self,
            action: #selector(closePressed)
        )
        navigationItem.rightBarButtonItem = closeButton
    }

    private func setupUI() {
        let elements = [
            nameCardView,
            notificationView,
            inviteView,
            helpView,
            logoutView,
            personalPrivacyContainerView
        ]

        elements.forEach { v in
            v?.layer.cornerRadius = 22
            v?.backgroundColor = .white
            v?.layer.masksToBounds = true
        }

        view.backgroundColor = UIColor.systemGray6
    }

    private func setupActions() {
        personalInfoButton.addTarget(self, action: #selector(openPersonalInfo), for: .touchUpInside)
        privacyButton.addTarget(self, action: #selector(openPrivacy), for: .touchUpInside)
        notificationView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openNotifications)))
        inviteView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openInvite)))
        helpView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openHelp)))
        logoutView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(logout)))
    }

    //  Push screens inside modal sheet
    @objc func openNotifications() {
        let vc = NotificationsViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc func openPersonalInfo() {
        let vc = PersonalInformationViewController()
        navigationController?.pushViewController(vc, animated: true)
        
        print("Personal Info tapped")
    }
    @objc func openPrivacy() {
        let vc = PrivacyandSecurityViewController()
        navigationController?.pushViewController(vc, animated: true)
        
        print("Privacy tapped")
    }
    @objc func openInvite() { print("Invite tapped") }
    @objc func openHelp() { print("Help tapped") }
    @objc func logout() { print("Logout tapped") }

    @objc func closePressed() {
        dismiss(animated: true, completion: nil)
    }
}

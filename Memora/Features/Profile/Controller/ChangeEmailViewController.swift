//
//  ChangeEmailViewController.swift
//  Memora
//
//  Created by user@3 on 19/11/25.
//

import UIKit

class ChangeEmailViewController: UIViewController {

    @IBOutlet weak var emailLabel: UITextField!
    @IBOutlet weak var emailView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Change Email"
        setupUI()
        setupNavBar()
    }

    private func setupUI() {
        let elements = [
            emailView
        ]

        elements.forEach { v in
            v?.layer.cornerRadius = 22
            v?.backgroundColor = .white
            v?.layer.masksToBounds = true
        }

        view.backgroundColor = UIColor.systemGray6
    }

    private func setupNavBar() {
        let checkmarkItem = UIBarButtonItem(
            image: UIImage(systemName: "checkmark"),
            style: .done,
            target: self,
            action: #selector(doneTapped)
        )
        navigationItem.rightBarButtonItem = checkmarkItem
    }

    @objc private func doneTapped() {
        navigationController?.popViewController(animated: true)
    }
}

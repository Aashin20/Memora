//
//  ChangePhoneViewController.swift
//  Memora
//
//  Created by user@3 on 20/11/25.
//

import UIKit

class ChangePhoneViewController: UIViewController {

    @IBOutlet weak var phoneView: UIView!
    @IBOutlet weak var phoneLabel: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Change Phone"
        setupUI()
        setupNavBar()
    }

    private func setupUI() {
        let elements = [
            phoneView
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

//
//  PersonalInformationViewController.swift
//  Memora
//
//  Created by user@3 on 13/11/25.
//

import UIKit

class PersonalInformationViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var cardView: UIView!
    
    @IBOutlet weak var firstNameLabel: UILabel!
    
    @IBOutlet weak var firstNameTextField: UITextField!
    
    
    @IBOutlet weak var lastNameLabel: UILabel!

    @IBOutlet weak var lastNameTextField: UITextField!
    
    @IBOutlet weak var dobLabel: UILabel!
    
    @IBOutlet weak var dobTextField: UITextField!
    
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var genderTextField: UITextField!
    
    // MARK: - Private properties
    private var isEditingMode = false
    private var editButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavBar()
        loadStaticData()
    }

    private func setupUI() {
        view.backgroundColor = UIColor.systemGray6
        cardView.layer.cornerRadius = 22
        cardView.layer.masksToBounds = true
        cardView.backgroundColor = .white
        
        // Make text fields non-editable initially
        [firstNameTextField, lastNameTextField, dobTextField, genderTextField].forEach {
            $0?.borderStyle = .none
            $0?.isUserInteractionEnabled = false
            $0?.textColor = .secondaryLabel
            $0?.font = UIFont.systemFont(ofSize: 16)
        }
    }
    
    private func setupNavBar() {
        title = "Personal Information"
        
        // Edit button setup
        editButton = UIBarButtonItem(
            title: "Edit",
            style: .plain,
            target: self,
            action: #selector(toggleEditMode)
        )
        navigationItem.rightBarButtonItem = editButton
    }

    private func loadStaticData() {
        firstNameTextField.text = "Robert"
        lastNameTextField.text = "Frost"
        dobTextField.text = "Nov 23, 1948"
        genderTextField.text = "Male"
    }
    
    // MARK: - Edit Mode Toggle
    @objc private func toggleEditMode() {
        isEditingMode.toggle()
        
        if isEditingMode {
            enableEditing()
            // Change edit button to tick icon
            let tickIcon = UIImage(systemName: "checkmark")
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                image: tickIcon,
                style: .plain,
                target: self,
                action: #selector(toggleEditMode)
            )
        } else {
            disableEditing()
            // Change back to edit text
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                title: "Edit",
                style: .plain,
                target: self,
                action: #selector(toggleEditMode)
            )
            saveChanges()
        }
    }
    
    private func enableEditing() {
        [firstNameTextField, lastNameTextField, dobTextField, genderTextField].forEach {
            $0?.isUserInteractionEnabled = true
            $0?.textColor = .label
        }
    }
    
    private func disableEditing() {
        [firstNameTextField, lastNameTextField, dobTextField, genderTextField].forEach {
            $0?.isUserInteractionEnabled = false
            $0?.textColor = .secondaryLabel
        }
    }
    
    private func saveChanges() {
        // Here you can save to user defaults, API, etc.
        print("Saved changes:")
        print("First Name: \(firstNameTextField.text ?? "")")
        print("Last Name: \(lastNameTextField.text ?? "")")
        print("DOB: \(dobTextField.text ?? "")")
        print("Gender: \(genderTextField.text ?? "")")
    }
}

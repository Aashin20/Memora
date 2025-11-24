//
//  PersonalInformationViewController.swift
//  Memora
//
//  Created by user@3 on 13/11/25.
//
//
//  PersonalInformationViewController.swift
//  Memora
//
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

    @IBOutlet weak var profileImageView: UIImageView!   // NEW

    // Pencil button created in code
    private let editProfileButton = UIButton(type: .custom)

    // MARK: - Private
    private var isEditingMode = false
    private var editButton: UIBarButtonItem!
    private let genderOptions = ["Male", "Female", "Other"]
    private var genderPicker = UIPickerView()
    private var datePicker = UIDatePicker()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavBar()
        setupProfileImage()
        setupPickers()
        loadStaticData()
    }

    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = UIColor.systemGray6

        cardView.layer.cornerRadius = 22
        cardView.layer.masksToBounds = true
        cardView.backgroundColor = .white

        [firstNameTextField, lastNameTextField, dobTextField, genderTextField].forEach {
            $0?.borderStyle = .none
            $0?.isUserInteractionEnabled = false
            $0?.textColor = .secondaryLabel
            $0?.font = UIFont.systemFont(ofSize: 16)
        }
    }

    private func setupNavBar() {
        title = "Personal Information"

        editButton = UIBarButtonItem(
            title: "Edit",
            style: .plain,
            target: self,
            action: #selector(toggleEditMode)
        )
        navigationItem.rightBarButtonItem = editButton
    }

    // MARK: - Profile Image Setup
    private func setupProfileImage() {
        profileImageView.layer.cornerRadius = 80
        profileImageView.layer.masksToBounds = true
        profileImageView.contentMode = .scaleAspectFill

        // Load default placeholder
        profileImageView.image = UIImage(named: "defaultProfile") ?? UIImage(systemName: "person.circle")

        // Setup pencil button
        editProfileButton.setImage(UIImage(systemName: "pencil"), for: .normal)
        editProfileButton.tintColor = .white
        editProfileButton.backgroundColor = .black.withAlphaComponent(0.8)
        editProfileButton.layer.cornerRadius = 16
        editProfileButton.clipsToBounds = true
        editProfileButton.isHidden = true
        editProfileButton.addTarget(self, action: #selector(changeProfileImage), for: .touchUpInside)

        view.addSubview(editProfileButton)
        editProfileButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            editProfileButton.widthAnchor.constraint(equalToConstant: 32),
            editProfileButton.heightAnchor.constraint(equalToConstant: 32),
            editProfileButton.trailingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: -6),
            editProfileButton.topAnchor.constraint(equalTo: profileImageView.topAnchor, constant: 6)
        ])
    }

    // MARK: - Pickers Setup
    private func setupPickers() {
        // Gender picker
        genderPicker.dataSource = self
        genderPicker.delegate = self
        genderTextField.inputView = genderPicker

        // Date picker
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.maximumDate = Date()
        dobTextField.inputView = datePicker
        datePicker.addTarget(self, action: #selector(didSelectDOB), for: .valueChanged)
    }

    @objc private func didSelectDOB() {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        dobTextField.text = formatter.string(from: datePicker.date)
    }

    // MARK: - Load Static Data
    private func loadStaticData() {
        firstNameTextField.text = "Robert"
        lastNameTextField.text = "Frost"
        dobTextField.text = "Nov 23, 1948"
        genderTextField.text = "Male"
    }

    // MARK: - Edit Toggle
    @objc private func toggleEditMode() {
        isEditingMode.toggle()

        if isEditingMode {
            enableEditing()

            navigationItem.rightBarButtonItem = UIBarButtonItem(
                image: UIImage(systemName: "checkmark"),
                style: .plain,
                target: self,
                action: #selector(toggleEditMode)
            )

            editProfileButton.isHidden = false

        } else {
            disableEditing()

            navigationItem.rightBarButtonItem = editButton

            editProfileButton.isHidden = true

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
        print("Saved changes:")
        print("First Name: \(firstNameTextField.text ?? "")")
        print("Last Name: \(lastNameTextField.text ?? "")")
        print("DOB: \(dobTextField.text ?? "")")
        print("Gender: \(genderTextField.text ?? "")")
    }

    // MARK: - Image Picker
    @objc private func changeProfileImage() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }
}

// MARK: - Image Picker Delegate
extension PersonalInformationViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        if let edited = info[.editedImage] as? UIImage {
            profileImageView.image = edited
        } else if let original = info[.originalImage] as? UIImage {
            profileImageView.image = original
        }

        dismiss(animated: true)
    }
}

// MARK: - Picker View Delegates
extension PersonalInformationViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        genderOptions.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        genderOptions[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        genderTextField.text = genderOptions[row]
    }
}

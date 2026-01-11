//
//  JoinGroupModalViewController.swift
//  Memora
//
//  Created by user@3 on 28/12/25.
//

import UIKit

class JoinGroupModalViewController: UIViewController {
    
    @IBOutlet weak var codeTextField: UITextField!
    @IBOutlet weak var joinButton: UIButton!
    @IBOutlet weak var cardView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Join Group"
        view.backgroundColor = UIColor.systemGray6
        
        setupNavigationBar()
        setupUI()
    }
    
    private func setupNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(close)
        )
    }
    
    private func setupUI() {
        cardView.layer.cornerRadius = 20
        cardView.backgroundColor = .white
        
        codeTextField.layer.cornerRadius = 12
        codeTextField.layer.borderWidth = 1
        codeTextField.layer.borderColor = UIColor.systemGray4.cgColor
        codeTextField.placeholder = "Enter 6-digit code"
        codeTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: codeTextField.frame.height))
        codeTextField.leftViewMode = .always
        codeTextField.autocapitalizationType = .allCharacters
        
        joinButton.layer.cornerRadius = 12
        joinButton.backgroundColor = .systemGreen
        
        codeTextField.becomeFirstResponder()
    }
    
    @IBAction func joinPressed(_ sender: UIButton) {
        let code = codeTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).uppercased() ?? ""
        
        if code.isEmpty {
            showAlert(title: "Error", message: "Please enter a group code")
            return
        }
        
        if code.count != 6 {
            showAlert(title: "Error", message: "Group code must be 6 characters")
            return
        }
        
        joinGroup(with: code)
    }
    
    private func joinGroup(with code: String) {
        let loadingAlert = UIAlertController(title: nil, message: "Joining group...", preferredStyle: .alert)
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = .medium
        loadingIndicator.startAnimating()
        loadingAlert.view.addSubview(loadingIndicator)
        present(loadingAlert, animated: true)
        
        Task {
            do {
                let group = try await SupabaseManager.shared.joinGroup(code: code)
                
                DispatchQueue.main.async {
                    loadingAlert.dismiss(animated: true) {
                        self.showSuccessAlert(group: group)
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    loadingAlert.dismiss(animated: true) {
                        self.showAlert(title: "Error", message: "Invalid or expired group code")
                    }
                }
            }
        }
    }
    
    private func showSuccessAlert(group: UserGroup) {
        let alert = UIAlertController(
            title: "Success!",
            message: "You have joined '\(group.name)'",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            self.dismissAndRefresh()
        })
        
        present(alert, animated: true)
    }
    
    private func dismissAndRefresh() {
        NotificationCenter.default.post(name: NSNotification.Name("GroupsListShouldRefresh"), object: nil)
        dismiss(animated: true)
    }
    
    @objc private func close() {
        dismiss(animated: true)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

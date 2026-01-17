import UIKit

protocol JoinGroupDelegate: AnyObject {
    func didJoinGroupSuccessfully()
}

class JoinGroupModalViewController: UIViewController {
    
    @IBOutlet weak var codeTextField: UITextField!
    @IBOutlet weak var joinButton: UIButton!
    @IBOutlet weak var cardView: UIView!
    
    weak var delegate: JoinGroupDelegate?
    
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
        let loadingAlert = UIAlertController(title: nil, message: "Sending join request...", preferredStyle: .alert)
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = .medium
        loadingIndicator.startAnimating()
        loadingAlert.view.addSubview(loadingIndicator)
        present(loadingAlert, animated: true)
        
        Task {
            do {
                _ = try await GroupsService.shared.joinGroup(code: code)
                
                DispatchQueue.main.async {
                    loadingAlert.dismiss(animated: true) {
                        // Show success message about pending approval
                        self.showPendingApprovalAlert(code: code)
                    }
                }
            } catch let error as NSError {
                DispatchQueue.main.async {
                    loadingAlert.dismiss(animated: true) {
                        // Handle specific error codes
                        var message = "Failed to join group"
                        
                        switch error.code {
                        case 404:
                            message = "Invalid group code. Please check and try again."
                        case 400:
                            if error.localizedDescription.contains("Already a member") {
                                message = "You are already a member of this group"
                            } else if error.localizedDescription.contains("Request already sent") {
                                message = "You have already sent a join request for this group"
                            } else {
                                message = error.localizedDescription
                            }
                        default:
                            message = error.localizedDescription
                        }
                        
                        self.showAlert(title: "Error", message: message)
                    }
                }
            }
        }
    }
    
    private func showPendingApprovalAlert(code: String) {
        let alert = UIAlertController(
            title: "Join Request Sent",
            message: "Your request to join the group has been sent. You'll be notified once an admin approves your request.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            self.dismissViewController()
        })
        
        present(alert, animated: true)
    }
    
    private func dismissViewController() {
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

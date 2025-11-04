//
//  AuthViewController.swift
//  Memora
//
//  Created by user@33 on 04/11/25.
//

import UIKit

class AuthViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var confirmPassTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var infoStackView: UIStackView!
    @IBOutlet weak var createAccountButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        let textFields = [nameTextField,emailTextField,passwordTextField,confirmPassTextField]
        textFields.forEach { textField in
            guard let textField = textField else { return }
            textField.layer.cornerRadius = 12
            textField.clipsToBounds = true
            textField.backgroundColor = .white
            
        }
        createAccountButton.layer.cornerRadius = 28
        createAccountButton.clipsToBounds = true
        createAccountButton.backgroundColor = .black
        createAccountButton.setTitleColor(.white, for: .normal)
        // Do any additional setup after loading the view.
        
        
        
        /*
         // MARK: - Navigation
         
         // In a storyboard-based application, you will often want to do a little preparation before navigation
         override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         // Get the new view controller using segue.destination.
         // Pass the selected object to the new view controller.
         }
         */
        
    }
}

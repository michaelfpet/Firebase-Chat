//
//  ViewController.swift
//  Firebase Chat
//
//  Created by Michael Foged Petersen on 03/02/2021.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {

    var username: String?
    
    @IBAction func unwindToLoginScreen(_ segue: UIStoryboardSegue) {
        try? Auth.auth().signOut()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareKeyboard()
        emailTextField.delegate = self
        passwordTextField.delegate = self
        nameTextField.delegate = self
    }
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - login or register action
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var registerOrLoginButton: UIButton!
    
    @IBOutlet weak var registerOrLoginSegmentedControl: UISegmentedControl!
    
    /// Tries to either login or register a user depending on the state of the segmented control.
    @IBAction func registerOrLogin(_ sender: UIButton) {
        view.endEditing(true)
        guard emailTextField.containsText, passwordTextField.containsText else { return }
        if registerOrLoginSegmentedControl.selectedSegmentIndex == Constants.loginIndex {
            loginUser()
        } else {
            guard nameTextField.containsText else { return }
            registerUser()
        }
    }
    
    /// Registers a new user with the email, password and name provided in the text fields.
    func registerUser() {
        guard let email = emailTextField.text,
              let password = passwordTextField.text,
              let name = nameTextField.text else {
            return
        }
        Server.registerUser(withEmail: email, password: password, username: name) { (success) in
            if success {
                self.performSegue(withIdentifier: Constants.showMessagesSegueID, sender: self)
            }
            self.activityIndicator.stopAnimating()
        }
        
        activityIndicator.startAnimating()
        Auth.auth().createUser(
            withEmail: email,
            password: password
        ) { (authResult, error) in
            self.activityIndicator.stopAnimating()
            if error != nil {
                print(error as Any)
                return
            }
            guard let user = Auth.auth().currentUser else { return }
            let ref = Database.database().reference().child(Constants.usersString).child(user.uid)
            ref.updateChildValues([Constants.userNameString: name])
            self.username = name
            self.performSegue(withIdentifier: Constants.showMessagesSegueID, sender: self)
        }
    }
    
    /// tries to login the user with the email and password provided in the text fields.
    func loginUser() {
        guard let email = emailTextField.text,
              let password = passwordTextField.text else {
            return
        }
        activityIndicator.startAnimating()
        Server.signInUser(withEmail: email, password: password) { (success) in
            if success {
                Server.getUsernameForCurrentUser { (username) in
                    self.username = username
                    self.performSegue(withIdentifier: Constants.showMessagesSegueID, sender: self)
                    self.activityIndicator.stopAnimating()
                }
            } else {
                self.activityIndicator.stopAnimating()
            }
        }
    }
    
    // MARK: - layout
    
    /// Called when the state of the segmented controll changes
    @IBAction func accessTypeChanged(_ sender:  UISegmentedControl) {
        view.endEditing(true)
        UIView.animate(withDuration: Constants.changeSetupTime) {
            if sender.selectedSegmentIndex == Constants.loginIndex {
                self.setupForLogin()
            } else {
                self.setupForRegister()
            }
        }
        
    }
    
    func setupForLogin() {
        registerOrLoginButton.setTitle("Login", for: .normal)
        nameTextField.isHidden = true
    }
    func setupForRegister() {
        registerOrLoginButton.setTitle("Register", for: .normal)
        nameTextField.isHidden = false
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.showMessagesSegueID {
            if let messagesCVC = segue.destination.contents as? MessagesCollectionViewController {
                // You shouldn't even try to segue unless the person has a name.
                messagesCVC.username = username!
            }
        }
    }
    
}

// MARK: - UITextField
extension LoginViewController: UITextFieldDelegate {
    func prepareKeyboard() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        switch textField {
        case emailTextField:
            passwordTextField.becomeFirstResponder()
        case passwordTextField:
            if registerOrLoginSegmentedControl.selectedSegmentIndex == Constants.registerIndex {
                nameTextField.becomeFirstResponder()
            }
        default:
            break
        }
        return true
        
    }
}

extension LoginViewController {
    struct Constants {
        
        static let showMessagesSegueID = "Show Messages"
        
        /// The key for the users in the database.
        static let usersString = "users"
        
        /// The key for a name inside the users in the database.
        static let userNameString = "name"
        
        /// The time to use for switching between login and register in the GUI.
        static let changeSetupTime = 0.4
                
        /// The index for login in the segmented control
        static let loginIndex = 0
        /// The index for register in the segmented control
        static let registerIndex = 1
    }
}

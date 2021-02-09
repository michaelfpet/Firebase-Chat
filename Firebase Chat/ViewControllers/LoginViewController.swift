//
//  ViewController.swift
//  Firebase Chat
//
//  Created by Michael Foged Petersen on 03/02/2021.
//

import UIKit

class LoginViewController: UIViewController {

    var username: String?
    
    @IBAction func unwindToLoginScreen(_ segue: UIStoryboardSegue) {
        Server.signOutUser()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareKeyboard()
        emailTextField.delegate = self
        passwordTextField.delegate = self
        nameTextField.delegate = self
        setTextFieldsText()
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
                self.username = name
                self.performSegue(withIdentifier: Constants.showMessagesSegueID, sender: self)
                self.storeTextFieldsText()
            }
            self.activityIndicator.stopAnimating()
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
                    self.username = username // TODO Check for nil here!
                    self.performSegue(withIdentifier: Constants.showMessagesSegueID, sender: self)
                    self.storeTextFieldsText()
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
    /// Sets the text in the email text field and password text field from the the corresponding value saved in user defaults.
    ///
    /// Update these properties by calling storeTextFieldsText()
    func setTextFieldsText() {
        let userDefaults = UserDefaults.standard
        emailTextField.text = userDefaults.string(forKey: Constants.emailKey)
        passwordTextField.text = userDefaults.string(forKey: Constants.passwordKey)
    }
    /// Stores the text in email and password text field in user defaults.
    func storeTextFieldsText() {
        let userDefaults = UserDefaults.standard
        userDefaults.setValue(emailTextField.text, forKey: Constants.emailKey)
        userDefaults.setValue(passwordTextField.text, forKey: Constants.passwordKey)
    }
}

extension LoginViewController {
    struct Constants {
        
        /// the key for the last entered email in userDefaults
        static let emailKey = "Email"
        /// the key for the last entered password in userDefaults
        static let passwordKey = "Password" // TODO, remove?
        
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

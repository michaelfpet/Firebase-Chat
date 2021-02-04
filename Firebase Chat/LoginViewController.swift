//
//  ViewController.swift
//  Firebase Chat
//
//  Created by Michael Foged Petersen on 03/02/2021.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {

    @IBAction func unwindToLoginScreen(_ segue: UIStoryboardSegue) {
        
    }
    
    @IBOutlet weak var NameTextField: UITextField! {
        didSet {
            NameTextField.delegate = self
        }
    }
    
    @IBAction func done(_ sender: UIButton) {
        if shouldPerformSegue(withIdentifier: "Show Messages", sender: self) {
            performSegue(withIdentifier: "Show Messages", sender: self)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "Show Messages" {
            if let messagesCVC = segue.destination.contents as? MessagesCollectionViewController {
                messagesCVC.personsName = NameTextField.text!
            }
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "Show Messages", !NameTextField.containsText { return false }
        return true
    }

}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if shouldPerformSegue(withIdentifier: "Show Messages", sender: self) {
            performSegue(withIdentifier: "Show Messages", sender: self)
        }
        return true
    }
}


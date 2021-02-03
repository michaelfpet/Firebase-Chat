//
//  ViewController.swift
//  Firebase Chat
//
//  Created by Michael Foged Petersen on 03/02/2021.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {

    
    @IBOutlet weak var NameTextField: UITextField! {
        didSet {
            NameTextField.delegate = self
        }
    }
    
    @IBAction func done(_ sender: UIButton) {
        let name = NameTextField.text
        
        // Check if the name is valid
        // if it is, then segue to the screen where it is possible to send messages.
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let ref = Database.database().reference(fromURL: "https://fir-chat-1d207-default-rtdb.firebaseio.com/")
    }


}

extension LoginViewController: UITextFieldDelegate {
    
    
    
}

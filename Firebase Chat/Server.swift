//
//  Server.swift
//  Firebase Chat
//
//  Created by Michael Foged Petersen on 09/02/2021.
//

import Foundation
import Firebase

struct Server {
    // MARK: - Authentication
    
    static func registerUser(withEmail email: String, password: String, username: String, completion: ((_ didSucceed: Bool) -> ())?) {
        Auth.auth().createUser(
            withEmail: email,
            password: password
        ) { (authResult, error) in
            if error != nil {
                print(error as Any)
                completion?(false)
            } else {
                setUsernameForCurrentUser(to: username)
                completion?(true)
            }
        }
    }
    
    static func signInUser(withEmail email: String, password: String, completion: ((_ didSucceed: Bool) -> ())?) {
        Auth.auth().signIn(
            withEmail: email,
            password: password
        ) { (authResult, error) in
            if error != nil {
                print(error as Any)
                completion?(false)
            } else {
                completion?(true)
            }
        }
    }
    
    // MARK: - Username
    
    /// A reference to where the users data is stored in the database.
    private static var userReference: DatabaseReference? {
        if let user = Auth.auth().currentUser {
            return Database.database().reference().child(Constants.usersString).child(user.uid)
        } else {
            return nil
        }
    }
    
    static func setUsernameForCurrentUser(to username: String) {
        userReference?.updateChildValues([Constants.userNameString: username])
    }
    
    // TODO find out what happens if there is asked for the username twice
    static func getUsernameForCurrentUser(completion: ((_ username: String?) -> ())?) {
        if let ref = userReference {
            ref.observeSingleEvent(of: .value) { (dataSnapshot) in
                let nameDictionary = dataSnapshot.value as? [String: AnyObject]
                let username = nameDictionary?[Constants.userNameString] as? String
                completion?(username)
            }
        } else {
            completion?(nil)
        }
    }
    
    // MARK: - Messages
    
    /// Sends a message by uploading it to the database, but only if the message has a sender, timestamp and message.
    /// - Parameter message: The message to send.
    static func sendMessage(_ message: Message) {
        guard message.hasValues else { return }
        let ref = Database.database().reference().child(Constants.messagesString)
        let childRef = ref.childByAutoId()
        let values = [
            Constants.messageString : message.text!,
            Constants.senderString : message.senderName!,
            Constants.timestampString : message.timestamp!
        ] as [String : Any]
        childRef.updateChildValues(values)
    }
    
    /// A reference to the location in the database where the messages are stored.
    private static var observingRefferenceToFirebase: DatabaseReference {
        Database.database().reference().child(Constants.messagesString)
    }
    
    /// Calls the given block for every message in the database and once whenever a message is added to the database.
    /// - Parameter block: The block to call whenever i message is added to the database.
    /// - Parameter message: The message recived from the server.
    static func observeMessages(with block: @escaping (_ message: Message) -> ()) {
        observingRefferenceToFirebase.observe(.childAdded) { dataSnapshot in
            guard let messageDictionary = dataSnapshot.value as? [String: AnyObject] else { return }
            var message = Message()
            message.setValues(withDictionary: messageDictionary)
            if message.hasValues {
                block(message)
            }
        }
    }
    static func stopObservingNewMessages() {
        observingRefferenceToFirebase.removeAllObservers()
    }
}

extension Server {
    struct Constants {
        /// The key for the users in the database.
        static let usersString = "users"
        
        /// The key for a name inside the users in the database.
        static let userNameString = "name"
        
        /// The name of the key for the messages in the database.
        static let messagesString = "messages"
        
        static let senderString = Message.Constants.senderString
        static let timestampString = Message.Constants.timestampString
        static let messageString = Message.Constants.messageString
    }
}

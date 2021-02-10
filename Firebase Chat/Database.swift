//
//  Server.swift
//  Firebase Chat
//
//  Created by Michael Foged Petersen on 09/02/2021.
//

import Foundation
import Firebase

struct Database {
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
    
    static func signOutUser() {
        do {
            try Auth.auth().signOut()
        } catch {
            print(error)
        }
    }
    
    // MARK: - Username
    
    /// A reference to where the users document is stored in the database.
    private static var userDocumentReference: DocumentReference? {
        if let user = Auth.auth().currentUser {
            return Firestore.firestore().collection(Constants.usersString).document(user.uid)
        } else {
            return nil
        }
    }
    
    static func setUsernameForCurrentUser(to username: String) {
        userDocumentReference?.setData([Constants.userNameString : username])
    }
    
    // TODO find out what happens if there is asked for the username twice? This could happen if the user changes his name.
    static func getUsernameForCurrentUser(completion: ((_ username: String?) -> ())?) {
        if let ref = userDocumentReference {
            ref.getDocument { (document, error) in
                if error != nil {
                    print(error as Any)
                }
                if let document = document, document.exists {
                    let value = document.data()?[Constants.userNameString] as? String
                    completion?(value)
                } else {
                    print("The users document does not exist")
                    completion?(nil)
                }
            }
        } else {
            completion?(nil)
        }
    }
    
    // MARK: - User id
    
    static func getUID() -> String? {
        if let user = Auth.auth().currentUser {
            return user.uid
        } else {
            return nil
        }
    }
    
    // MARK: - Messages
    
    /// The collection where the messages are stoed within
    private static var messagesCollectionReference: CollectionReference {
        Firestore.firestore().collection(Constants.messagesString)
    }
    
    /// Sends a message by uploading it to the database, but only if the message has a sender, timestamp and message.
    /// - Parameter message: The message to send.
    static func sendMessage(_ message: Message) {
        guard message.hasValues else { return }
        let document = messagesCollectionReference.document()
        let values = [
            Constants.messageString : message.text!,
            Constants.senderString : message.senderName!,
            Constants.timestampString : message.timestamp!,
            Constants.senderUIDString : message.senderUID!
        ] as [String : Any]
        document.setData(values)
    }
    
    private static var listeners = [ListenerRegistration]()
    
    /// Calls the given block whener a message is added to the database and once with every message in the database when this is first called.
    /// - Parameter block: The block to call whenever messages are recived.
    /// - Parameter messages: The messages recived from the server.
    static func observeMessages(with block: @escaping (_ messages: [Message]) -> ()) {
        let listener = messagesCollectionReference.addSnapshotListener { (querySnapshot, error) in
            if error != nil {
                print(error as Any)
                return
            }
            var messages = [Message]()
            guard querySnapshot != nil else { return }
            for documentChange in querySnapshot!.documentChanges {
                var message = Message()
                message.setValues(withDictionary: documentChange.document.data())
                if message.hasValues { messages.append(message) }
            }
            block(messages)
        }
        listeners.append(listener)
    }
    static func stopObservingNewMessages() {
        listeners.forEach { $0.remove() }
    }
}

extension Database {
    struct Constants {
        /// The key for the users in the database.
        static let usersString = "users"
        
        /// The key for a name inside the users in the database.
        static let userNameString = "name"
        
        /// The name of the key for the messages in the database.
        static let messagesString = "messages"
        
        // The keys for the properties af a message stored in the database.
        static let senderString = Message.Constants.senderString
        static let timestampString = Message.Constants.timestampString
        static let messageString = Message.Constants.messageString
        static let senderUIDString = Message.Constants.senderUIDString
    }
}

//
//  MessagesCollectionViewController.swift
//  Firebase Chat
//
//  Created by Michael Foged Petersen on 03/02/2021.
//

import UIKit

class MessagesCollectionViewController: UICollectionViewController {
    
    var username = "Michael"
    
    var messages = [Message]()
    
    // MARK: - Controllers life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.alwaysBounceVertical = true
        collectionView.contentInset = UIEdgeInsets(
            top: 0,
            left: 0,
            bottom: Constants.containerViewHeight + Constants.CollectionViewBottomInset,
            right: 0)
        makeInputComponent()
        prepareForKeyboard()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        observeMessages()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        Server.stopObservingNewMessages()
    }
    
    // MARK: - Input Component
    
    lazy var textField: UITextField = {
        let _textField = UITextField()
        _textField.delegate = self
        _textField.placeholder = Constants.textFieldText
        _textField.translatesAutoresizingMaskIntoConstraints = false
        return _textField
    }()
    
    var containerView: UIView = {
        let _containerView = UIView()
        _containerView.translatesAutoresizingMaskIntoConstraints = false
        _containerView.backgroundColor = .white
        return _containerView
    }()
    
    // A refence to this constraint is needed to move the container view up when the keyboard appears.
    var containerViewBottmConstraint: NSLayoutConstraint?
    
    
    /// Makes the input text field at the bottom of the screen with a send bottom and white background
    func makeInputComponent() {
        // Container view.
        view.addSubview(containerView)
        containerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        containerViewBottmConstraint = containerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        containerViewBottmConstraint?.isActive = true
        containerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: Constants.containerViewHeight).isActive = true
        
        // Send Button.
        let sendButton = UIButton(type: .system)
        sendButton.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
        sendButton.setTitle("Send", for: .normal)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(sendButton)
        sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: Constants.sendButtonWidth).isActive = true
        sendButton.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        // Text field.
        view.addSubview(textField)
        textField.leftAnchor.constraint(
            equalTo: containerView.leftAnchor,
            constant: Constants.textFieldInset).isActive = true
        textField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        textField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
        textField.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        // Thin line above container view.
        let lineView = UIView()
        lineView.backgroundColor = .lightGray
        lineView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(lineView)
        lineView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        lineView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        lineView.bottomAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        lineView.heightAnchor.constraint(equalToConstant: Constants.lineViewWidth).isActive = true
        
        // This white rect is added at the bottom to ensure the messages doesn't get shown underneath the container view.
        let BottomRect = UIView()
        BottomRect.backgroundColor = .white
        BottomRect.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(BottomRect)
        BottomRect.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        BottomRect.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        BottomRect.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        BottomRect.topAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
    }
    
    // MARK: - Logout
    
    @IBAction func logout(_ sender: UIBarButtonItem) {
        view.endEditing(true)
        performSegue(
            withIdentifier: "Unwind To Login Screen", sender: self
        )
    }
}

// MARK: - UICollectionViewDataSource
extension MessagesCollectionViewController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.reuseIdentifier, for: indexPath)
        if let messageCell = cell as? MessageCollectionViewCell {
            
            let message = messages[indexPath.item]
            messageCell.senderAndTimeLabel.text = message.info
            messageCell.messageLabel.text = message.text
            
            messageCell.isTrailing = username == message.senderName
            messageCell.messageWidth = view.frame.width * Constants.messageWidthRatio
        }
        return cell
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout
extension MessagesCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width * Constants.cellsWidthRatio, height: Constants.cellsDefaultHeight)
    }
}

// MARK: - UITextField
extension MessagesCollectionViewController: UITextFieldDelegate {
    
    /// Adds observers for when the keyboard gets shown or hidden, and a gesture recognizer to remove keyboard when the viewgets tapped.
    func prepareForKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            containerViewBottmConstraint?.constant = view.safeAreaInsets.bottom - keyboardSize.height
            UIView.animate(withDuration: 0.5) {
                self.view.layoutIfNeeded()
            }
        }
    }
    @objc func keyboardWillHide(notification: Notification) {
        containerViewBottmConstraint?.constant = 0.0
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - Firebase
extension MessagesCollectionViewController {
    /// Uploads the message written in the text field to the databse with a timestamp and the senders name.
    @objc private func sendMessage() {
        guard textField.containsText else { return }
        let timestamp = Date.timeIntervalSinceReferenceDate as Double
        let message = Message(
            senderName: username,
            timestamp: timestamp,
            text: textField.text!)
        Server.sendMessage(message)
        textField.text = ""
        textField.resignFirstResponder()
    }
    
    /// Sets up an obser to to add new messages whenever they apper in the database.
    func observeMessages() {
        // Messages shouldn't be observed multiple times so all observings are stopped before a new one is instantiated.
        Server.stopObservingNewMessages()
        messages.removeAll(keepingCapacity: true)
        Server.observeMessages { [weak self] (message) in
            DispatchQueue.main.async {
                self?.messages.append(contentsOf: message)
                self?.collectionView.reloadData()
            }
        }
    }
}

// MARK: - Constants
extension MessagesCollectionViewController {
    struct Constants {
        static let reuseIdentifier = "Message Cell"
        
        /// The name of the key for the messages in the database.
        static let messagesString = "messages"
        
        static let senderString = Message.Constants.senderString
        static let timestampString = Message.Constants.timestampString
        static let messageString = Message.Constants.messageString
        
        /// The placerholder text in the text filed.
        static let textFieldText = "Enter message."
        
        
        // MARK: View ratios.
        /// How much the cells are moved in from the edge. Making this number smaller moves the messages towards the middle of the screen.
        static let cellsWidthRatio: CGFloat = 0.95
        static let cellsDefaultHeight: CGFloat = 80.0
        /// The ratio between the messages and views width.
        static let messageWidthRatio: CGFloat = 0.7
        /// A Constant the Collection view cells can be moved above the place for entering a message at the bottom.
        static let CollectionViewBottomInset: CGFloat = 30.0
        
        //  MARK: Container view.
        /// The width of the line right above the container view.
        static let lineViewWidth: CGFloat = 1.0
        
        static let containerViewHeight: CGFloat = 50.0
        
        static let sendButtonWidth: CGFloat = 80.0
        
        /// A constant for moving the text field in from the left.
        static let textFieldInset: CGFloat = 8.0
    }
}

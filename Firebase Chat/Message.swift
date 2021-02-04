//
//  Message.swift
//  Firebase Chat
//
//  Created by Michael Foged Petersen on 03/02/2021.
//

import Foundation

struct Message {
    var senderName: String?
    var timestamp: Double?
    var text: String?
    
    /// Returns a string composed of the senders name and when the message was send.
    var info: String {
        if let timestamp = timestamp {
            let date = Date(timeIntervalSinceReferenceDate: timestamp)
            let formatter = DateFormatter()
            formatter.dateFormat = "d MMM y, HH:mm"
            let dateString = formatter.string(from: date)
            return (senderName ?? "Unkown") + " - " + dateString
        } else {
            return senderName ?? "Unkown"
        }
        
    }
    
    /// This is a fail safe version of setValuesForKeys.
    ///
    /// Use this instead of setValuesForKeys because it for some reason doesn't work.
    mutating func setValues(withDictionary dictionary: [String: Any]) {
        if let senderName = dictionary["senderName"] as? String? {
            self.senderName = senderName
        }
        if let timestamp = dictionary["timestamp"] as? Double? {
            self.timestamp = timestamp
        }
        if let text = dictionary["text"] as? String? {
            self.text = text
        }
    }
}

extension Message {
    struct Constants {
        // These must match the name of the variables in Message exactly!
        static let senderString = "senderName"
        static let timestampString = "timestamp"
        static let messageString = "text"
    }
}

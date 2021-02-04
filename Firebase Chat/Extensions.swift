//
//  Extensions.swift
//  Firebase Chat
//
//  Created by Michael Foged Petersen on 04/02/2021.
//

import UIKit

extension UIViewController {
    /// returns the visible view controller if it is a navigation controller, othervise the viewController itself. Useful for segue.
    var contents: UIViewController {
        if let navcon = self as? UINavigationController {
            return navcon.visibleViewController ?? navcon
        } else {
            return self
        }
    }
}

extension UITextField {
    /// Returns true if the text field's text doesn't contain an empty string and isn't nil.
    var containsText: Bool {
        self.text != nil && self.text != ""
    }
}

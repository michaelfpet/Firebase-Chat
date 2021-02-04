//
//  MessageCollectionViewCell.swift
//  Firebase Chat
//
//  Created by Michael Foged Petersen on 03/02/2021.
//

import UIKit

class MessageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var senderAndTimeLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    // MARK: - layout
    
    /// Whether or not the cells content should be alligned leading or trailing.
    var isTrailing = false {
        didSet {
            if isTrailing {
                cellLeadingEqualConstraint?.isActive = false
                cellTrailingEqualConstraint?.isActive = true
            } else {
                cellTrailingEqualConstraint?.isActive = false
                cellLeadingEqualConstraint?.isActive = true
            }
        }
    }
    
    /// The width of the message.
    var messageWidth: CGFloat {
        set {
            cellWidthConstraint.constant = newValue
        }
        get {
            cellWidthConstraint.constant
        }
    }
    
    @IBOutlet private weak var cellWidthConstraint: NSLayoutConstraint!
    
    // The constraints are made strong, otherwise they will get removed as soon as they get get deactivated, which causes problems when cells gets reused.
    @IBOutlet private var cellLeadingEqualConstraint: NSLayoutConstraint! {
        didSet {
            cellLeadingEqualConstraint.isActive = !isTrailing
        }
    }
    @IBOutlet private var cellTrailingEqualConstraint: NSLayoutConstraint! {
        didSet {
            cellTrailingEqualConstraint.isActive = isTrailing
        }
    }
}





//
//  MessageLabel.swift
//  Firebase Chat
//
//  Created by Michael Foged Petersen on 04/02/2021.
//

import UIKit


class MessageLabel: UILabel {
    
    // MARK: - initialisation
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        clipsToBounds = true
        layer.cornerRadius = Constants.cornerRadius
    }
    
    // MARK: - Padding
    // These methoads have been overridden to add padding.
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: insets))
    }
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(
            width: size.width + Constants.padding * 2,
            height: size.height + Constants.padding * 2
        )
    }
    
    override var bounds: CGRect {
        didSet {
            // Ensures this works within stack views if multiline.
            preferredMaxLayoutWidth = bounds.width - (Constants.padding * 2)
        }
    }
}

extension MessageLabel {
    struct Constants {
        static let padding: CGFloat = 10.0
        static let cornerRadius: CGFloat = 8.0
    }
    
    var insets: UIEdgeInsets {
        UIEdgeInsets(
            top: Constants.padding,
            left: Constants.padding,
            bottom: Constants.padding,
            right: Constants.padding)
    }
}

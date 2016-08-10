//
//  MinutesButton.swift
//  IMeditated
//
//  Created by Bob Spryn on 8/15/16.
//  Copyright © 2016 Thumbworks. All rights reserved.
//

import UIKit

@IBDesignable class MinutesButton: UIButton {
    @IBInspectable var minutes: UInt = 0
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.white
        self.setTitleColor(UIColor(named: .spicyMix), for: .normal)
        self.layer.shadowRadius = 5
        self.layer.shadowOpacity = 0.15
        self.layer.shadowOffset = CGSize.zero
        self.layer.shadowColor = UIColor(named: .spicyMix).cgColor
    }
}

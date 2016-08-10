//
//  MinutesEntryCell.swift
//  IMeditated
//
//  Created by Bob Spryn on 9/16/16.
//  Copyright © 2016 Thumbworks. All rights reserved.
//

import UIKit

class MinutesEntryCell: UITableViewCell {

    @IBOutlet private var durationLabel: UILabel!
    @IBOutlet private var endedLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.durationLabel.textColor = UIColor(named: .spicyMix)
        self.endedLabel.textColor = UIColor(named: .richBlack)
        // embolden our dynamic font from IB
        self.durationLabel.font = UIFont.init(descriptor: self.durationLabel.font.fontDescriptor.withSymbolicTraits(.traitBold)!, size: 0)
    }
    
    func renderWithViewModel(viewModel: MinutesEntryViewModel) {
        self.durationLabel.text = viewModel.duration
        self.endedLabel.text = viewModel.ended
    }
    
}

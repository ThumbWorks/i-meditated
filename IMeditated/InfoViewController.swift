//
//  InfoViewController.swift
//  IMeditated
//
//  Created by Bob Spryn on 2/2/17.
//  Copyright © 2017 Thumbworks. All rights reserved.
//

import UIKit
import RxCocoa

class InfoViewController: UIViewController {

    @IBOutlet var doneButton: UIBarButtonItem!
    @IBOutlet var dividers: [UIView]!
    @IBOutlet var textView: UITextView!
    
    lazy var doneButtonTap: ControlEvent<Void> = {
        self.doneButton.rx.tap
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(named: .dutchWhite)
        self.dividers.forEach { (divider) in
            divider.backgroundColor = UIColor(named: .spicyMix)
        }
        
        if let rtfPath = Bundle.main.url(forResource: "About", withExtension: "rtf") {
            do {
                let attributedStringWithRtf = try NSAttributedString(url: rtfPath, options: [NSDocumentTypeDocumentAttribute:NSRTFTextDocumentType], documentAttributes: nil)
                textView.attributedText = attributedStringWithRtf
            } catch {
                print("No rtf content found!")
            }
        }
    }
    
    @IBAction func twlogoTapped(_ sender: Any) {
        if let url = URL(string: "http://thumbworks.io") {
            UIApplication.shared.open(url, options:[:] )
        }
    }
}

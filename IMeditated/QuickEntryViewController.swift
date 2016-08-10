//
//  ViewController.swift
//  IMeditated
//
//  Created by Bob Spryn on 8/9/16.
//  Copyright © 2016 Thumbworks. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

protocol QuickEntryViewModelType {
    var todaysDuration: Driver<String?> { get }
    var yesterdaysDuration: Driver<String?> { get }
}


class QuickEntryViewController: UIViewController {

    @IBOutlet private var quickEntryButtons: [MinutesButton]!
    @IBOutlet private var customButton: UIButton!
    @IBOutlet private var todayDurationLabel: UILabel!
    @IBOutlet private var yesterdayDurationLabel: UILabel!
    @IBOutlet private var todayTextLabel: UILabel!
    @IBOutlet private var yesterdayTextLabel: UILabel!
    
    let actionModel: MainContextActionsType!
    let viewModel: QuickEntryViewModelType!
    
    private let disposables = DisposeBag()
    
    let listNavButton = UIBarButtonItem.init(barButtonSystemItem: .bookmarks, target: nil, action: nil)
    let infoButton = UIButton(type: UIButtonType.infoDark)
    lazy var infoBarButton:UIBarButtonItem = UIBarButtonItem(customView: self.infoButton)
    
    // expose a listTap event for the coordinator to tie navigation into
    lazy var listTap: ControlEvent<Void> = {
        self.listNavButton.rx.tap
    }()

    // expose an info tap event for the coordinator to tie navigation into
    lazy var infotap: ControlEvent<Void> = {
        self.infoButton.rx.tap
    }()
    
    // We use a subject as the inbetween for the UIControl and the exposed observable below
    // mainly because the custom tap behavior is setup before the view loads
    private let customTapSubject = PublishSubject<Void>()
    
    // expose a customDurtion tap event for the coordinator to tie navigation into
    lazy var customTap: Observable<Void> = {
        self.customTapSubject.asObservable()
    }()
    
    init(viewModel: QuickEntryViewModelType, actionModel:MainContextActionsType) {
        self.actionModel = actionModel
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.navigationItem.rightBarButtonItem = self.listNavButton
        self.navigationItem.leftBarButtonItem = self.infoBarButton
        // grab the initial meditations
        actionModel.fetchMeditations()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(named: .dutchWhite)
        
        self.todayDurationLabel.textColor = UIColor(named: .richBlack)
        self.todayTextLabel.textColor = UIColor(named: .richBlack)
        self.todayTextLabel.font = UIFont.init(descriptor: self.todayTextLabel.font.fontDescriptor.withSymbolicTraits(.traitBold)!, size: 0)

        self.yesterdayDurationLabel.textColor = UIColor(named: .spicyMix)
        self.yesterdayTextLabel.textColor = UIColor(named: .spicyMix)
        
        customButton.backgroundColor = UIColor.white
        customButton.setTitleColor(UIColor(named: .spicyMix), for: .normal)
        customButton.layer.cornerRadius = 10
        customButton.layer.shadowRadius = 5
        customButton.layer.shadowOpacity = 0.15
        customButton.layer.shadowOffset = CGSize.zero
        customButton.layer.shadowColor = UIColor(named: .spicyMix).cgColor
        
        // connect the tap to the subject
        customButton.rx.tap.subscribe(self.customTapSubject)
            .addDisposableTo(self.disposables)
        
        self.quickEntryButtons.forEach { button in
            button.rx.tap.subscribe(onNext: { [unowned self] value in
                self.actionModel.saveMeditation(minutes: button.minutes)
            }).addDisposableTo(self.disposables)
        }
        
        self.viewModel.todaysDuration
            .drive(self.todayDurationLabel.rx.text)
            .addDisposableTo(self.disposables)

        self.viewModel.yesterdaysDuration
            .drive(self.yesterdayDurationLabel.rx.text)
            .addDisposableTo(self.disposables)
    }
    
    override func viewDidLayoutSubviews() {
        self.quickEntryButtons.forEach { button in
            button.layer.cornerRadius = button.frame.size.width/2
        }
    }
}


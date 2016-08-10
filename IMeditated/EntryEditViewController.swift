//
//  EntryEditViewController.swift
//  IMeditated
//
//  Created by Bob Spryn on 9/17/16.
//  Copyright © 2016 Thumbworks. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class EntryEditViewController: UIViewController {

    @IBOutlet private var startTimeHeader: UILabel!
    @IBOutlet var startDatePicker: UIDatePicker!
    @IBOutlet private var durationHeader: UILabel!
    
    @IBOutlet var endDatePicker: UIDatePicker!
    @IBOutlet var borders: [UIView]!
    private var addDoneButton: UIBarButtonItem!
    private var cancelButton: UIBarButtonItem!
    
    // alternatively, keep scratch as a second property? Informs that it should be it's own file?
    let viewModel: EntryEditViewModelComboType
    
    let actionModel: MainContextActionsType
    
    lazy var cancelTap: ControlEvent<Void> = {
        self.cancelButton.rx.tap
    }()
    
    let disposables = DisposeBag()
    
    init(viewModel: EntryEditViewModelComboType, actionModel: MainContextActionsType) {
        self.viewModel = viewModel
        self.actionModel = actionModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addDoneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: nil)
        self.cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: nil, action: nil)
        
        self.navigationItem.leftBarButtonItem = self.cancelButton
        self.navigationItem.rightBarButtonItem = self.addDoneButton
        
        self.title = self.viewModel.configuration.title()
        
        self.view.backgroundColor = UIColor(named: .dutchWhite)
        
        self.startDatePicker.backgroundColor = UIColor.white
        self.endDatePicker.backgroundColor = UIColor.white
        
        self.borders.forEach { border in
            border.backgroundColor = UIColor(named: .spicyMix)
        }

        // subscribe the view model to updates from the UI for temporary state storage
        // also update the temporary state storage with any changes from the view model
        let uiStartChange = self.startDatePicker.rx.date
            .skip(1)
        
        Observable.of(uiStartChange, self.viewModel.currentStart).merge()
            .distinctUntilChanged()
            .subscribe(self.viewModel.setStartDate)
            .addDisposableTo(self.disposables)
        
        let uiEndChange = self.endDatePicker.rx.date
            .skip(1)

        Observable.of(uiEndChange, self.viewModel.currentEnd).merge()
            .distinctUntilChanged()
            .subscribe(self.viewModel.setEndDate)
            .addDisposableTo(self.disposables)
        
        // subscribe the UI to updates from the view model
        self.viewModel.currentStart
            .subscribe(self.startDatePicker.rx.date)
            .addDisposableTo(self.disposables)
        self.viewModel.currentEnd
            .subscribe(self.endDatePicker.rx.date)
            .addDisposableTo(self.disposables)
        
        Observable.combineLatest(self.viewModel.currentEnd, self.viewModel.currentDuration) { return ($0, $1) }
            .sample(self.addDoneButton.rx.tap)
            .subscribe(onNext: { [unowned self] (end, duration) in
                if let originalStart = self.viewModel.originalStart,
                    let originalEnd = self.viewModel.originalEnd {
                    self.actionModel.moveMeditation(originalStart: originalStart, originalEnd: originalEnd, end: end, duration: duration)
                } else {
                    self.actionModel.saveMeditation(endDate: end, minutes: duration)
                }
            })
            .addDisposableTo(self.disposables)
        
    }

}

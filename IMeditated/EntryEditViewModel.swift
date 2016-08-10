//
//  EntryEditViewModel.swift
//  IMeditated
//
//  Created by Bob Spryn on 9/19/16.
//  Copyright © 2016 Thumbworks. All rights reserved.
//

import Foundation
import RxSwift

enum EntryEditConfiguration {
    case create, edit
    func title() -> String {
        switch self {
        case .create:
            return tr(.customSample)
        case .edit:
            return tr(.editSample)
        }
    }
}

protocol EntryEditViewModelType {
    // if we are starting with an existing one, those dates will be saved in these properties
    var originalStart: Date? { get }
    var originalEnd: Date? { get }
    var configuration: EntryEditConfiguration { get }
    
    // these update with the latest values, restricting the start and end from going past one another
    var currentStart: Observable<Date> { get }
    var currentEnd: Observable<Date> { get }
    var currentDuration: Observable<UInt> { get }
}

protocol EntryEditScratchStateType {
    // Expose subjects that will be updated via the UI to track user changes
    // this is the only "mutable" part exposed to the VC
    var setStartDate: BehaviorSubject<Date> {get}
    var setEndDate: BehaviorSubject<Date> {get}
}

protocol EntryEditViewModelComboType: EntryEditViewModelType, EntryEditScratchStateType {}

class EntryEditViewModel: EntryEditViewModelComboType {
    
    let originalStart: Date?
    let originalEnd: Date?
    
    let configuration: EntryEditConfiguration
    
    // strip the hour, minutes, seconds, nano
    let startDate = Calendar.current.date(from:Calendar.current.dateComponents([.year,.month,.day], from: Date()))!
 
    lazy var setStartDate:BehaviorSubject<Date> = {
        BehaviorSubject(value:self.originalStart ?? self.startDate)
    }()
    
    lazy var setEndDate:BehaviorSubject<Date> = {
        BehaviorSubject(value:self.originalEnd ?? self.startDate)
    }()
    
    lazy var currentStart: Observable<Date> = {
        Observable.combineLatest(self.setStartDate.distinctUntilChanged(), self.setEndDate.distinctUntilChanged()) { start, end in
            return start > end ? end : start
        }
    }()
    
    lazy var currentEnd: Observable<Date> = {
        Observable.combineLatest(self.setStartDate.distinctUntilChanged(), self.setEndDate.distinctUntilChanged()) { start, end in
            return end < start ? start : end
        }
    }()
    
    lazy var currentDuration: Observable<UInt> = {
        return Observable.combineLatest(self.currentStart, self.currentEnd) { start, end in
            let interval = end.timeIntervalSince(start)
            return UInt(ceil(interval/60.0))
        }
    }()
    
    init(start: Date?, end: Date?, configuration: EntryEditConfiguration) {
        self.originalStart = start
        self.originalEnd = end
        self.configuration = configuration
    }
}

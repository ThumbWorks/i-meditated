//
//  MinutesListViewModel.swift
//  IMeditated
//
//  Created by Bob Spryn on 8/17/16.
//  Copyright © 2016 Thumbworks. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa



class MinutesListViewModel: MinutesListViewModelType {
    
    // TODO: Add tests around this sorting and grouping?
    let minutesSamplesGroups: Driver<([String], [String: [MinutesEntryViewModel]])>
    
    init(minutesListContext: MainContextStateType) {
        self.minutesSamplesGroups = minutesListContext.allMeditationSamples
            .observeOn(SerialDispatchQueueScheduler(globalConcurrentQueueQOS: .userInitiated))
            .map { $0.map(MinutesEntryViewModel.init) }
            .map { entries in
                return entries.categorize { $0.day }
            }.asDriver(onErrorDriveWith: Driver.just(([], [:])))
    }
}


// Move somewhere shared, add tests
public extension Sequence {
    func categorize<U : Hashable>( keyFunc: (Iterator.Element) -> U) -> ([U], [U:[Iterator.Element]]) {
        var dict: [U:[Iterator.Element]] = [:]
        var keys: [U] = []
        for el in self {
            let key = keyFunc(el)
            if(!keys.contains(key)) {
                keys.append(key)
                dict[key] = [el]
            } else {
                dict[key]?.append(el)
            }
        }
        return (keys, dict)
    }
}

//
//  QuickEntryViewModel.swift
//  IMeditated
//
//  Created by Bob Spryn on 10/5/16.
//  Copyright © 2016 Thumbworks. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class QuickEntryViewModel: QuickEntryViewModelType {
    private let context: MainContextStateType
    
    // may want to request just samples for today and yesterday in a future iteration
    // as the number of samples being parsed here could get quite large.
    private lazy var durations:Driver<(String, String)> = {
        let timeChangeSampler = self.context.allMeditationSamples
            .sample(NotificationCenter.default.rx.notification(.UIApplicationSignificantTimeChange))
            .distinctUntilChanged {
                return $0 == $1
            }
        
        return Observable.of(self.context.allMeditationSamples, timeChangeSampler).merge()
            .observeOn(SerialDispatchQueueScheduler(globalConcurrentQueueQOS: .userInitiated))
            .map(QuickEntryViewModel.calculateDurationStrings)
            .asDriver(onErrorJustReturn: ("¯\\_(ツ)_/¯", "¯\\_(ツ)_/¯"))
    }()
    
    lazy var todaysDuration: Driver<String?> = {
        self.durations.map { durations in
            let (start, _) = durations
            return start
        }
    }()
    
    lazy var yesterdaysDuration: Driver<String?> = {
        self.durations.map { durations in
            let (_, end) = durations
            return end
        }
    }()

    init(context: MainContextStateType) {
        self.context = context
    }
    
    static func calculateDurationStrings(samples: [MeditationSample]) -> (String, String) {
        let now = Date()
        let adjustDay = DateComponents(day:-1)
        let yesterday = Calendar.current.date(byAdding: adjustDay, to: now)!
        guard case let .success(_, todayEnd) = now.generateStartAndEndDateForDay(),
            case let .success(yesterdayStart, _) = yesterday.generateStartAndEndDateForDay() else {
                return ("¯\\_(ツ)_/¯", "¯\\_(ツ)_/¯")
        }
        
        // filter in two passes
        let filteredSamples = samples.filter { sample in
            return (sample.start >= yesterdayStart ||
                sample.end <= todayEnd)
        }
        
        let todayDurationInterval = filteredSamples.totalDuration(onDate: now)
        let yesterdayDurationInterval = filteredSamples.totalDuration(onDate: yesterday)

        guard let todayDuration = Formatters.durationFormatter.string(from: todayDurationInterval),
            let yesterdayDuration = Formatters.durationFormatter.string(from: yesterdayDurationInterval) else {
                return ("¯\\_(ツ)_/¯", "¯\\_(ツ)_/¯")
        }
        return (todayDuration, yesterdayDuration)
    }
}

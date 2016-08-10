//
//  MeditationSample.swift
//  IMeditated
//
//  Created by Bob Spryn on 8/19/16.
//  Copyright © 2016 Thumbworks. All rights reserved.
//

import Foundation
import HealthKit

struct MeditationSample {
    let start: Date
    let end: Date
}

extension MeditationSample {
    init(sample: HKSample) {
        self.start = sample.startDate
        self.end = sample.endDate
    }
}

extension MeditationSample {
    func overlaps(candidateSample: MeditationSample) -> Bool {
        return (self.start <= candidateSample.end && candidateSample.start <= self.start) ||
            (self.end >= candidateSample.start &&  self.start <= candidateSample.start)
    }
}

extension MeditationSample: Equatable {
    static func == (lhs: MeditationSample, rhs: MeditationSample) -> Bool {
        return lhs.start == rhs.start && lhs.end == rhs.end
    }
}

enum MeditationRangeDirection {
    case MovingForward, MovingBackward
}

extension Collection where Iterator.Element == MeditationSample {
    
    func findAnyTimeRangeTodayWhereSampleFits(startDate: Date, durationInMinutes minutes: UInt)  -> MeditationSample? {
        if let sample = self.findTimeRangeTodayWhereSampleFits(direction: .MovingForward, startDate: startDate, durationInMinutes: minutes) {
            return sample
        }
        return self.findTimeRangeTodayWhereSampleFits(direction: .MovingBackward, startDate: startDate, durationInMinutes: minutes)
    }
    
    // this doesn't really enforce that the samples are all today, but it wouldn't be super helpful if they weren't
    // probably not the best design
    func findTimeRangeTodayWhereSampleFits(direction: MeditationRangeDirection, startDate: Date, durationInMinutes minutes: UInt)  -> MeditationSample? {
        let endDate = Date(timeInterval: Double(minutes) * 60, since: startDate)
        let initialSample = MeditationSample(start: startDate, end: endDate)
        
        return self.sorted(by: { sampleA, sampleB in
            // sort order depends on which direction we're trying to insert the sample
            return direction == .MovingForward ? sampleA.end < sampleB.end : sampleA.start > sampleB.start
        }).reduce(initialSample, { currentSample, candidateSample -> MeditationSample? in
            // if we already found out it doesn't fit, just return
            guard let currentSample = currentSample else { return nil }
            
            // if the current range overlaps the sample, then try and bump it
            // else just return it
            guard currentSample.overlaps(candidateSample: candidateSample) else { return currentSample }
            
            // if the overlapping sample has enough time left in the day, return a new sample
            // if not, we've reach the end of the possible samples, so return nil
            switch direction {
                case .MovingForward:
                    switch candidateSample.end.hasNumberOfMinutesRemainingInDay(minutes) {
                        case .success:
                            return MeditationSample(start:candidateSample.end, end: Date(timeInterval: Double(minutes) * 60, since: candidateSample.end))
                        case .failure:
                            return nil
                    }
                case .MovingBackward:
                    switch candidateSample.end.hasNumberOfMinutesInDayBefore(minutes) {
                        case .success:
                            return MeditationSample(start:Date(timeInterval: Double(minutes) * -60, since: candidateSample.start), end: candidateSample.start)
                        case .failure:
                            return nil
                    }
            }
        })
    }
    
    func totalDuration() -> TimeInterval {
        return self.reduce(0) { total, sample in
            return total + (sample.end.timeIntervalSince(sample.start))
        }
    }
    
    func totalDuration(onDate date: Date) -> TimeInterval {
        let dateComponents = Calendar.current.dateComponents([.year,.month,.day], from: date)
        var nextDayComponents = dateComponents
        nextDayComponents.day = nextDayComponents.day.map { day -> Int in
            day + 1
        }
        
        let date = Calendar.current.date(from: dateComponents)!
        let nextDay = Calendar.current.date(from: nextDayComponents)!
        
        let dateTimeInterval = date.timeIntervalSince1970
        let nextDayTimeInterval = nextDay.timeIntervalSince1970
        
        // high level filter
        return self.filter { sample -> Bool in
            return (sample.start >= date && sample.start < nextDay) || (sample.end >= date && sample.end < nextDay)
        }
        // find duration that overlaps the day in question
        .reduce(0) { (total, sample) -> TimeInterval in
            // get time intervals for date, nextDate, start and stop
            
            let sampleStartInterval = sample.start.timeIntervalSince1970
            let sampleEndInterval = sample.end.timeIntervalSince1970

            // if the start is on the date
            if sample.start >= date {
                let endForCalc = Swift.min(sampleEndInterval, nextDayTimeInterval)
                return total + (endForCalc - sampleStartInterval)
            // otherwise, it's the end
            } else {
                let startForCalc = Swift.max(sampleStartInterval, dateTimeInterval)
                return total + sampleEndInterval - (startForCalc)
            }

        }
    }
}

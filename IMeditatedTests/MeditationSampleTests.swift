//
//  MainContextTests.swift
//  IMeditated
//
//  Created by Bob Spryn on 9/8/16.
//  Copyright © 2016 Thumbworks. All rights reserved.
//

import XCTest
@testable import IMeditated

class MeditationSampleTests: XCTestCase {
    
    func testFindingTimeRangeThatFitsWhereNoneOverlap() {
        var samples:[MeditationSample] = []
        var startDateComponents = DateComponents(year: 2016, month: 7, day: 1, hour: 19, minute: 20, second: 23, nanosecond: 3)
        var startDate = Calendar.current.date(from: startDateComponents)!
        var endDateComponents = DateComponents(year: 2016, month: 7, day: 1, hour: 19, minute: 40, second: 23, nanosecond: 3)
        var endDate = Calendar.current.date(from: endDateComponents)!
        
        samples.append(MeditationSample(start:startDate, end:endDate))
        
        startDateComponents = DateComponents(year: 2016, month: 7, day: 1, hour: 20, minute: 24, second: 23, nanosecond: 3)
        startDate = Calendar.current.date(from: startDateComponents)!
        endDateComponents = DateComponents(year: 2016, month: 7, day: 1, hour: 20, minute: 46, second: 23, nanosecond: 3)
        endDate = Calendar.current.date(from: endDateComponents)!
        
        samples.append(MeditationSample(start:startDate, end:endDate))
        
        startDateComponents = DateComponents(year: 2016, month: 7, day: 1, hour: 22, minute: 40, second: 23, nanosecond: 3)
        startDate = Calendar.current.date(from: startDateComponents)!
        endDateComponents = DateComponents(year: 2016, month: 7, day: 1, hour: 23, minute: 10, second: 23, nanosecond: 3)
        endDate = Calendar.current.date(from: endDateComponents)!
        
        samples.append(MeditationSample(start:startDate, end:endDate))
        
        let initialDateComponents = DateComponents(year: 2016, month: 7, day: 1, hour: 18, minute: 22, second: 23, nanosecond: 3)
        let initialDate = Calendar.current.date(from: initialDateComponents)!
        
        let sample30Min = samples.findTimeRangeTodayWhereSampleFits(direction: .MovingForward,startDate: initialDate, durationInMinutes: 30)
        
        XCTAssertEqual(initialDate, sample30Min?.start)
    }
    
    func testFindingTimeRangeThatFitsMovingForwardWhereThereIsOverlap() {
        var samples:[MeditationSample] = []
        
        var startDateComponents = DateComponents(year: 2016, month: 7, day: 1, hour: 20, minute: 24, second: 23, nanosecond: 3)
        let startDate2 = Calendar.current.date(from: startDateComponents)!
        var endDateComponents = DateComponents(year: 2016, month: 7, day: 1, hour: 21, minute: 46, second: 23, nanosecond: 3)
        let endDate2 = Calendar.current.date(from: endDateComponents)!
        
        samples.append(MeditationSample(start:startDate2, end:endDate2))
        
        startDateComponents = DateComponents(year: 2016, month: 7, day: 1, hour: 19, minute: 20, second: 23, nanosecond: 3)
        let startDate = Calendar.current.date(from: startDateComponents)!
        endDateComponents = DateComponents(year: 2016, month: 7, day: 1, hour: 19, minute: 40, second: 23, nanosecond: 3)
        let endDate = Calendar.current.date(from: endDateComponents)!
        
        samples.append(MeditationSample(start:startDate, end:endDate))

        startDateComponents = DateComponents(year: 2016, month: 7, day: 1, hour: 22, minute: 40, second: 23, nanosecond: 3)
        let startDate3 = Calendar.current.date(from: startDateComponents)!
        endDateComponents = DateComponents(year: 2016, month: 7, day: 1, hour: 23, minute: 10, second: 23, nanosecond: 3)
        let endDate3 = Calendar.current.date(from: endDateComponents)!
        
        samples.append(MeditationSample(start:startDate3, end:endDate3))
        
        
        let initialDateComponents = DateComponents(year: 2016, month: 7, day: 1, hour: 19, minute: 10, second: 23, nanosecond: 3)
        let initialDate = Calendar.current.date(from: initialDateComponents)!
        
        let result30min = samples.findTimeRangeTodayWhereSampleFits(direction: .MovingForward, startDate: initialDate, durationInMinutes: 30)
        let result60min = samples.findTimeRangeTodayWhereSampleFits(direction: .MovingForward, startDate: initialDate, durationInMinutes: 60)
        
        XCTAssertEqual(endDate, result30min?.start)
        XCTAssertNil(result60min)
    }
    
    func testFindingTimeRangeThatFitsMovingBackwardWhereThereIsOverlap() {
        var samples:[MeditationSample] = []
        
        var startDateComponents = DateComponents(year: 2016, month: 7, day: 1, hour: 16, minute: 20, second: 23, nanosecond: 3)
        let startDate2 = Calendar.current.date(from: startDateComponents)!
        var endDateComponents = DateComponents(year: 2016, month: 7, day: 1, hour: 16, minute: 54, second: 23, nanosecond: 3)
        let endDate2 = Calendar.current.date(from: endDateComponents)!
        
        samples.append(MeditationSample(start:startDate2, end:endDate2))
        
        startDateComponents = DateComponents(year: 2016, month: 7, day: 1, hour: 18, minute: 24, second: 23, nanosecond: 3)
        let startDate = Calendar.current.date(from: startDateComponents)!
        endDateComponents = DateComponents(year: 2016, month: 7, day: 1, hour: 19, minute: 20, second: 23, nanosecond: 3)
        let endDate = Calendar.current.date(from: endDateComponents)!
        
        samples.append(MeditationSample(start:startDate, end:endDate))
        
        startDateComponents = DateComponents(year: 2016, month: 7, day: 1, hour: 17, minute: 00, second: 23, nanosecond: 3)
        let startDate3 = Calendar.current.date(from: startDateComponents)!
        endDateComponents = DateComponents(year: 2016, month: 7, day: 1, hour: 17, minute: 45, second: 23, nanosecond: 3)
        let endDate3 = Calendar.current.date(from: endDateComponents)!
        
        samples.append(MeditationSample(start:startDate3, end:endDate3))
        
        
        let initialDateComponents = DateComponents(year: 2016, month: 7, day: 1, hour: 19, minute: 10, second: 23, nanosecond: 3)
        let initialDate = Calendar.current.date(from: initialDateComponents)!
        
        let result30min = samples.findTimeRangeTodayWhereSampleFits(direction: .MovingBackward, startDate: initialDate, durationInMinutes: 30)
        let result60min = samples.findTimeRangeTodayWhereSampleFits(direction: .MovingBackward, startDate: initialDate, durationInMinutes: 60)
        
        XCTAssertEqual(startDate, result30min?.end)
        XCTAssertEqual(startDate2, result60min?.end)
    }
    
    func testOverlapsFalse() {
        let startDateComponents = DateComponents(year: 2016, month: 7, day: 1, hour: 20, minute: 24, second: 23, nanosecond: 3)
        let startDate = Calendar.current.date(from: startDateComponents)!
        let endDateComponents = DateComponents(year: 2016, month: 7, day: 1, hour: 21, minute: 46, second: 23, nanosecond: 3)
        let endDate = Calendar.current.date(from: endDateComponents)!
        
        let startDateComponents2 = DateComponents(year: 2016, month: 7, day: 1, hour: 22, minute: 24, second: 23, nanosecond: 3)
        let startDate2 = Calendar.current.date(from: startDateComponents2)!
        let endDateComponents2 = DateComponents(year: 2016, month: 7, day: 1, hour: 23, minute: 46, second: 23, nanosecond: 3)
        let endDate2 = Calendar.current.date(from: endDateComponents2)!
        
        let currentSample = MeditationSample(start: startDate, end: endDate)
        let candidateSample = MeditationSample(start: startDate2, end: endDate2)
        
        XCTAssertFalse(currentSample.overlaps(candidateSample: candidateSample))
    }
    
    func testOverlapsBeginning() {
        let startDateComponents = DateComponents(year: 2016, month: 7, day: 1, hour: 20, minute: 24, second: 23, nanosecond: 3)
        let startDate = Calendar.current.date(from: startDateComponents)!
        let endDateComponents = DateComponents(year: 2016, month: 7, day: 1, hour: 21, minute: 46, second: 23, nanosecond: 3)
        let endDate = Calendar.current.date(from: endDateComponents)!
        
        let startDateComponents2 = DateComponents(year: 2016, month: 7, day: 1, hour: 19, minute: 24, second: 23, nanosecond: 3)
        let startDate2 = Calendar.current.date(from: startDateComponents2)!
        let endDateComponents2 = DateComponents(year: 2016, month: 7, day: 1, hour: 20, minute: 25, second: 23, nanosecond: 3)
        let endDate2 = Calendar.current.date(from: endDateComponents2)!
        
        let currentSample = MeditationSample(start: startDate, end: endDate)
        let candidateSample = MeditationSample(start: startDate2, end: endDate2)
        
        XCTAssertTrue(currentSample.overlaps(candidateSample: candidateSample))
    }
    
    func testOverlapsEnding() {
        let startDateComponents = DateComponents(year: 2016, month: 7, day: 1, hour: 20, minute: 24, second: 23, nanosecond: 3)
        let startDate = Calendar.current.date(from: startDateComponents)!
        let endDateComponents = DateComponents(year: 2016, month: 7, day: 1, hour: 21, minute: 46, second: 23, nanosecond: 3)
        let endDate = Calendar.current.date(from: endDateComponents)!
        
        let startDateComponents2 = DateComponents(year: 2016, month: 7, day: 1, hour: 21, minute: 42, second: 23, nanosecond: 3)
        let startDate2 = Calendar.current.date(from: startDateComponents2)!
        let endDateComponents2 = DateComponents(year: 2016, month: 7, day: 1, hour: 22, minute: 25, second: 23, nanosecond: 3)
        let endDate2 = Calendar.current.date(from: endDateComponents2)!
        
        let currentSample = MeditationSample(start: startDate, end: endDate)
        let candidateSample = MeditationSample(start: startDate2, end: endDate2)
        
        XCTAssertTrue(currentSample.overlaps(candidateSample: candidateSample))
    }
    
    func testOverlapsIdentical() {
        let startDateComponents = DateComponents(year: 2016, month: 7, day: 1, hour: 20, minute: 24, second: 23, nanosecond: 3)
        let startDate = Calendar.current.date(from: startDateComponents)!
        let endDateComponents = DateComponents(year: 2016, month: 7, day: 1, hour: 21, minute: 46, second: 23, nanosecond: 3)
        let endDate = Calendar.current.date(from: endDateComponents)!
        
        let currentSample = MeditationSample(start: startDate, end: endDate)
        let candidateSample = MeditationSample(start: startDate, end: endDate)
        
        XCTAssertTrue(currentSample.overlaps(candidateSample: candidateSample))
    }
    
    func testCalculatesCorrectDurationForSamples() {
        let startDateComponents = DateComponents(year: 2016, month: 7, day: 1, hour: 20, minute: 24, second: 0, nanosecond: 0)
        let startDate = Calendar.current.date(from: startDateComponents)!
        let endDateComponents = DateComponents(year: 2016, month: 7, day: 1, hour: 21, minute: 27, second: 0, nanosecond: 0)
        let endDate = Calendar.current.date(from: endDateComponents)!
        
        let startDateComponents2 = DateComponents(year: 2016, month: 7, day: 1, hour: 21, minute: 42, second: 0, nanosecond: 0)
        let startDate2 = Calendar.current.date(from: startDateComponents2)!
        let endDateComponents2 = DateComponents(year: 2016, month: 7, day: 1, hour: 22, minute: 22, second: 0, nanosecond: 0)
        let endDate2 = Calendar.current.date(from: endDateComponents2)!
        
        let currentSample = MeditationSample(start: startDate, end: endDate)
        let candidateSample = MeditationSample(start: startDate2, end: endDate2)
        XCTAssertEqual([currentSample, candidateSample].totalDuration(), 103 * 60)
    }
    
    func testCalculatesCorrectDurationIncludingOverlap() {
        let startDateComponents = DateComponents(year: 2016, month: 7, day: 1, hour: 23, minute: 24, second: 0, nanosecond: 0)
        let startDate = Calendar.current.date(from: startDateComponents)!
        let endDateComponents = DateComponents(year: 2016, month: 7, day: 2, hour: 0, minute: 4, second: 0, nanosecond: 0)
        let endDate = Calendar.current.date(from: endDateComponents)!
        
        let startDateComponents2 = DateComponents(year: 2016, month: 7, day: 1, hour: 23, minute: 42, second: 0, nanosecond: 0)
        let startDate2 = Calendar.current.date(from: startDateComponents2)!
        let endDateComponents2 = DateComponents(year: 2016, month: 7, day: 2, hour: 0, minute: 0, second: 0, nanosecond: 0)
        let endDate2 = Calendar.current.date(from: endDateComponents2)!
        
        let currentSample = MeditationSample(start: startDate, end: endDate)
        let candidateSample = MeditationSample(start: startDate2, end: endDate2)
        
        let testDateComponents = DateComponents(year: 2016, month: 7, day: 1)
        
        XCTAssertEqual([currentSample, candidateSample].totalDuration(onDate: Calendar.current.date(from: testDateComponents)!), (36 + 18) * 60)
    }
    
}

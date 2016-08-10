//
//  MainContextTests.swift
//  IMeditated
//
//  Created by Bob Spryn on 8/31/16.
//  Copyright © 2016 Thumbworks. All rights reserved.
//

import XCTest
@testable import IMeditated
import RxCocoa

class DateToolsTests: XCTestCase {
    
    // test that passing a date in pulls out the correct dates with zeroed out times
    func testDateSelectionUtilityFunction() {
        let dateComponents = DateComponents(year: 2016, month: 7, day: 1, hour: 19, minute: 20, second: 23, nanosecond: 3)
        let date = Calendar.current.date(from: dateComponents)
        self.makeDateAssertionsWithDate(date: date!)
        
        let earlyDateComponents = DateComponents(year: 2016, month: 7, day: 1, hour: 0, minute: 20, second: 23, nanosecond: 3)
        let earlyDate = Calendar.current.date(from: earlyDateComponents)
        self.makeDateAssertionsWithDate(date: earlyDate!)
    }
    
    func makeDateAssertionsWithDate(date: Date) {
        let startComponents = DateComponents(year: 2016, month: 7, day: 1, hour: 0, minute: 0, second: 0, nanosecond: 0)
        let startDate = Calendar.current.date(from: startComponents)
        
        let endComponents = DateComponents(year: 2016, month: 7, day: 2, hour: 0, minute: 0, second: 0, nanosecond: 0)
        let endDate = Calendar.current.date(from: endComponents)
        
        let result = date.generateStartAndEndDateForDay()
        guard case let .success(resultStart, resultEnd) = result else {
            XCTAssert(false)
            return
        }
        XCTAssertEqual(startDate!, resultStart)
        XCTAssertEqual(endDate!, resultEnd)
    }
    
    func testFalseyMinutesLeftInDate() {
        var dateComponents = DateComponents(year: 2016, month: 7, day: 1, hour: 23, minute: 20, second: 23, nanosecond: 3)
        var date = Calendar.current.date(from: dateComponents)
        guard case .failure = date!.hasNumberOfMinutesRemainingInDay(60) else {
            XCTAssert(false)
            return
        }
        dateComponents = DateComponents(year: 2016, month: 7, day: 1, hour: 23, minute: 00, second: 01, nanosecond: 0)
        date = Calendar.current.date(from: dateComponents)
        guard case .failure = date!.hasNumberOfMinutesRemainingInDay(60) else {
            XCTAssert(false)
            return
        }
    }
    
    func testTruthyMinutesLeftInDate() {
        var dateComponents = DateComponents(year: 2016, month: 7, day: 1, hour: 22, minute: 20, second: 23, nanosecond: 3)
        var date = Calendar.current.date(from: dateComponents)
        guard case .success = date!.hasNumberOfMinutesRemainingInDay(60) else {
            XCTAssert(false)
            return
        }
        dateComponents = DateComponents(year: 2016, month: 7, day: 1, hour: 22, minute: 59, second: 59, nanosecond: 0)
        date = Calendar.current.date(from: dateComponents)
        guard case .success = date!.hasNumberOfMinutesRemainingInDay(60) else {
            XCTAssert(false)
            return
        }
    }
    
    func testAdjustsStartDateToFitMinutes() {
        let dateComponents = DateComponents(year: 2016, month: 7, day: 1, hour: 23, minute: 20, second: 23, nanosecond: 3)
        let date = Calendar.current.date(from: dateComponents)!
        let adjusted = date.shiftTimeToFitRangeInDay(withMinutes: 60)
        guard case let .success(adjustedDate) = adjusted else {
            XCTAssert(false)
            return
        }
        
        let adjustMinutes = DateComponents(minute:-20)
        let matchDate = Calendar.current.date(byAdding: adjustMinutes, to: date)
        
        XCTAssertNotEqual(date, adjustedDate)
        XCTAssertEqual(matchDate, adjustedDate)
        XCTAssert(date > adjustedDate)
    }
    
    func testDoesntAdjustStartDateToFitMinutes() {
        let dateComponents = DateComponents(year: 2016, month: 7, day: 1, hour: 22, minute: 20, second: 23, nanosecond: 3)
        let date = Calendar.current.date(from: dateComponents)!
        let adjusted = date.shiftTimeToFitRangeInDay(withMinutes: 60)
        guard case let .success(adjustedDate) = adjusted else {
            XCTAssert(false)
            return
            
        }
        XCTAssertEqual(date, adjustedDate)
    }
}

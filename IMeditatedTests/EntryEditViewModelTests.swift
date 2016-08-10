//
//  EntryEditViewModelTests.swift
//  IMeditated
//
//  Created by Bob Spryn on 9/20/16.
//  Copyright © 2016 Thumbworks. All rights reserved.
//

import XCTest
@testable import IMeditated

class EntryEditViewModelTests: XCTestCase {
    
    func testUpdatingStartLaterThanEndChangesEnd() {
        let dateComponents = DateComponents(year: 2016, month: 7, day: 1, hour: 19, minute: 20, second: 0, nanosecond: 0)
        let date = Calendar.current.date(from: dateComponents)

        let dateComponents2 = DateComponents(year: 2016, month: 7, day: 1, hour: 20, minute: 20, second: 0, nanosecond: 0)
        let date2 = Calendar.current.date(from: dateComponents2)

        let dateComponents3 = DateComponents(year: 2016, month: 7, day: 1, hour: 21, minute: 20, second: 0, nanosecond: 0)
        let date3 = Calendar.current.date(from: dateComponents3)!

        
        let viewModel = EntryEditViewModel(start: date, end: date2, configuration: .create)
        
        
        let expectation = self.expectation(description: "Sends a second value")
        let _ = viewModel.currentEnd
            .skip(1)
            .subscribe(onNext: { value in
                expectation.fulfill()
                XCTAssertEqual(value, date3)
            })
        
        viewModel.setStartDate.onNext(date3)
        
        self.waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testUpdatingEndEarlierThanStartChangesStart() {
        let dateComponents = DateComponents(year: 2016, month: 7, day: 1, hour: 19, minute: 20, second: 0, nanosecond: 0)
        let date = Calendar.current.date(from: dateComponents)
        
        let dateComponents2 = DateComponents(year: 2016, month: 7, day: 1, hour: 20, minute: 20, second: 0, nanosecond: 0)
        let date2 = Calendar.current.date(from: dateComponents2)
        
        let dateComponents3 = DateComponents(year: 2016, month: 7, day: 1, hour: 18, minute: 20, second: 0, nanosecond: 0)
        let date3 = Calendar.current.date(from: dateComponents3)!
        
        
        let viewModel = EntryEditViewModel(start: date, end: date2, configuration: .create)
        

        let expectation = self.expectation(description: "Sends a second value")
        let _ = viewModel.currentStart
            .skip(1)
            .subscribe(onNext: { value in
                expectation.fulfill()
                XCTAssertEqual(value, date3)
            })
        
        viewModel.setEndDate.onNext(date3)

        self.waitForExpectations(timeout: 1, handler: nil)
    }
    
}

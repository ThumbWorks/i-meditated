//
//  IMeditatedUITests.swift
//  IMeditatedUITests
//
//  Created by Roderic Campbell on 2/6/17.
//  Copyright © 2017 Thumbworks. All rights reserved.
//

import XCTest

class IMeditatedUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func authorizeHealthKit() {
        let app = XCUIApplication()
        let tablesQuery = app.tables
        tablesQuery.children(matching: .cell).matching(identifier: "Mindful Minutes").element(boundBy: 0).switches["Mindful Minutes"].tap()
        tablesQuery.children(matching: .cell).matching(identifier: "Mindful Minutes").element(boundBy: 1).switches["Mindful Minutes"].tap()
        app.navigationBars["Health Access"].buttons["Allow"].tap()
    }
    func addAFewHoursOfMeditation() {
        let app = XCUIApplication()
        app.buttons["Custom Duration"].tap()
        
        let startPicker = app.datePickers["start-date"]
        startPicker.pickerWheels["12 o’clock"].adjust(toPickerWheelValue: "1")
        startPicker.pickerWheels["00 minutes"].adjust(toPickerWheelValue: "04")
        let endPicker = app.datePickers["stop-date"]
        endPicker.pickerWheels["11 o’clock"].adjust(toPickerWheelValue: "1")
        endPicker.pickerWheels["00 minutes"].adjust(toPickerWheelValue: "51")
        snapshot("1CreateMeditation")
        app.navigationBars.buttons["Cancel"].tap()
    }
    
    func testPopulateTheApp() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()
        
        authorizeHealthKit()
        snapshot("0MainScreen")
        addAFewHoursOfMeditation()
        XCUIApplication().navigationBars["IMeditated.QuickEntryView"].buttons["Bookmarks"].tap()
        snapshot("2ViewData")
    }
    
}

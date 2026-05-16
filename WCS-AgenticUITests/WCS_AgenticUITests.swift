//
//  WCS_AgenticUITests.swift
//  WCS-AgenticUITests
//

import XCTest

final class WCS_AgenticUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["--uitesting"]
        app.launch()
    }

    @MainActor
    func testProgramsTabAndHealthUX() throws {
        let programs = app.tabBars.buttons["Programs"]
        XCTAssertTrue(programs.waitForExistence(timeout: 8))
        programs.tap()

        let refresh = app.buttons["Refresh API"]
        XCTAssertTrue(refresh.waitForExistence(timeout: 5))
        refresh.tap()

        let enroll = app.buttons["Enroll sample"]
        XCTAssertTrue(enroll.waitForExistence(timeout: 5))
        enroll.tap()

        let apiTab = app.tabBars.buttons["API"]
        XCTAssertTrue(apiTab.waitForExistence(timeout: 5))
        apiTab.tap()

        let ping = app.buttons["Ping"]
        XCTAssertTrue(ping.waitForExistence(timeout: 5))
        ping.tap()

        XCTAssertTrue(app.staticTexts["ok"].waitForExistence(timeout: 8))
    }

    @MainActor
    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            let a = XCUIApplication()
            a.launchArguments = ["--uitesting"]
            a.launch()
        }
    }
}

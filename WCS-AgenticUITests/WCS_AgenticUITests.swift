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

    /// Selects a tab by accessibility id or label, opening the More menu when tabs overflow.
    private func tapTab(identifier: String, label: String) {
        let tabBar = app.tabBars.firstMatch
        let byId = tabBar.buttons[identifier]
        if byId.waitForExistence(timeout: 3) {
            byId.tap()
            return
        }
        let byLabel = tabBar.buttons.matching(
            NSPredicate(format: "label CONTAINS[c] %@", label)
        ).firstMatch
        if byLabel.waitForExistence(timeout: 3) {
            byLabel.tap()
            return
        }
        let more = tabBar.buttons["More"]
        if more.waitForExistence(timeout: 2) {
            more.tap()
            let overflow = app.buttons.matching(
                NSPredicate(format: "label CONTAINS[c] %@", label)
            ).firstMatch
            if overflow.waitForExistence(timeout: 3) {
                overflow.tap()
                return
            }
        }
        XCTFail("Could not select tab '\(label)' (id: \(identifier))")
    }

    @MainActor
    func testProgramsTabAndHealthUX() throws {
        tapTab(identifier: "tab.programs", label: "Programs")

        let refresh = app.buttons["toolbar.refreshHealth"]
        if refresh.waitForExistence(timeout: 3) {
            refresh.tap()
        } else {
            app.buttons["Refresh API"].tap()
        }

        tapTab(identifier: "tab.monitor", label: "Monitor")

        let refreshMonitor = app.buttons["monitor.refreshHealth"]
        XCTAssertTrue(refreshMonitor.waitForExistence(timeout: 8))
        refreshMonitor.tap()

        let okPredicate = NSPredicate(format: "label CONTAINS[c] %@", "ok")
        XCTAssertTrue(app.staticTexts.matching(okPredicate).firstMatch.waitForExistence(timeout: 12))
    }

    @MainActor
    func testAgentsAndApprovalsTabs() throws {
        tapTab(identifier: "tab.agents", label: "Agents")
        XCTAssertTrue(app.navigationBars["Agents"].waitForExistence(timeout: 8))

        tapTab(identifier: "tab.approvals", label: "Approvals")
        XCTAssertTrue(app.navigationBars["Approvals"].waitForExistence(timeout: 8))
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

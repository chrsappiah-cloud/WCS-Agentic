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
        addUIInterruptionMonitor(withDescription: "Local Network Permission") { alert in
            let allow = alert.buttons["Allow"]
            if allow.exists {
                allow.tap()
                return true
            }

            let ok = alert.buttons["OK"]
            if ok.exists {
                ok.tap()
                return true
            }

            return false
        }

        if isLiveBackendTest && shouldRunLiveBackendTest {
            app.launchArguments = ["--livebackend", "--start-finance"]
            app.launchEnvironment["WCS_API_BASE_URL"] = liveBackendBaseURL()
        } else {
            app.launchArguments = launchArguments(for: name)
        }
        app.launch()
        app.tap()
    }

    private var isLiveBackendTest: Bool {
        name.contains("testFinanceAILiveBackendCommandsGenerateGovernanceReport")
    }

    private var shouldRunLiveBackendTest: Bool {
        ProcessInfo.processInfo.environment["WCS_RUN_LIVE_BACKEND_UI_TESTS"] == "1"
            || FileManager.default.fileExists(atPath: "/tmp/wcs-live-backend-base-url")
    }

    private func liveBackendBaseURL() -> String {
        if let baseURL = ProcessInfo.processInfo.environment["WCS_API_BASE_URL"], !baseURL.isEmpty {
            return baseURL
        }
        let marker = URL(fileURLWithPath: "/tmp/wcs-live-backend-base-url")
        if let value = try? String(contentsOf: marker, encoding: .utf8)
            .trimmingCharacters(in: .whitespacesAndNewlines),
            !value.isEmpty
        {
            return value
        }
        return "http://192.168.20.217:8081"
    }

    private func launchArguments(for testName: String) -> [String] {
        var arguments = ["--uitesting"]
        if testName.contains("testBlueprintPerformanceMonitorLoadsPortfolioSignals") {
            arguments.append(contentsOf: ["--start-blueprint", "--start-blueprint-performance"])
        } else if testName.contains("LegalDeepSeek") {
            arguments.append("--start-legal")
        } else if testName.contains("ProgramsTab") || testName.contains("AppStoreScreenshotSet") {
            arguments.append("--start-programs")
        } else if testName.contains("Agents") {
            arguments.append("--start-agents")
        } else if testName.contains("FinanceAI") {
            arguments.append("--start-finance")
        }
        return arguments
    }

    private func launchArgument(forTabLabel label: String) -> String? {
        switch label {
        case "Finance AI":
            return "--start-finance"
        case "Legal AI":
            return "--start-legal"
        case "Programs":
            return "--start-programs"
        case "Agents":
            return "--start-agents"
        case "Blueprint":
            return "--start-blueprint"
        case "Approvals":
            return "--start-approvals"
        case "Monitor":
            return "--start-monitor"
        case "API":
            return "--start-api"
        case "Account":
            return "--start-account"
        case "Admin":
            return "--start-admin"
        default:
            return nil
        }
    }

    private func relaunch(startingAt label: String) {
        guard let tabArgument = launchArgument(forTabLabel: label) else {
            return
        }
        var arguments = ["--uitesting", tabArgument]
        if label == "Blueprint" && name.contains("testBlueprintPerformanceMonitorLoadsPortfolioSignals") {
            arguments.append("--start-blueprint-performance")
        }
        app.terminate()
        app.launchArguments = arguments
        app.launch()
        app.tap()
    }

    /// Selects a tab by accessibility id or label, opening the More menu when tabs overflow.
    private func tapTab(identifier: String, label: String) {
        if tabSelectionMarker(for: label).waitForExistence(timeout: 2) {
            return
        }

        relaunch(startingAt: label)
        if tabSelectionMarker(for: label).waitForExistence(timeout: 8) {
            return
        }

        let visibleTabX: [String: CGFloat] = [
            "Finance AI": 0.12,
            "Legal AI": 0.32,
            "Programs": 0.52,
            "Agents": 0.72,
            "Blueprint": 0.92,
        ]
        if let x = visibleTabX[label] {
            app.coordinate(withNormalizedOffset: CGVector(dx: x, dy: 0.96)).tap()
            if tabSelectionMarker(for: label).waitForExistence(timeout: 5) {
                return
            }
        }

        let tabBar = app.tabBars.firstMatch
        let byId = tabBar.buttons.matching(identifier: identifier).firstMatch
        if byId.waitForExistence(timeout: 3) {
            byId.tap()
            if tabSelectionMarker(for: label).waitForExistence(timeout: 3) {
                return
            }
        }

        let exactVisible = app.buttons.matching(
            NSPredicate(format: "label == %@", label)
        ).firstMatch
        if exactVisible.waitForExistence(timeout: 1) {
            exactVisible.tap()
            if tabSelectionMarker(for: label).waitForExistence(timeout: 3) {
                return
            }
        }

        let byLabel = tabBar.buttons.matching(
            NSPredicate(format: "label CONTAINS[c] %@", label)
        ).firstMatch
        if byLabel.waitForExistence(timeout: 3) {
            byLabel.tap()
            if tabSelectionMarker(for: label).waitForExistence(timeout: 3) {
                return
            }
        }
        let more = tabBar.buttons["More"]
        if more.waitForExistence(timeout: 2) {
            more.tap()
            let predicate = NSPredicate(format: "label CONTAINS[c] %@", label)
            let candidates = [
                app.buttons.matching(predicate).firstMatch,
                app.cells.matching(predicate).firstMatch,
                app.staticTexts.matching(predicate).firstMatch,
                app.descendants(matching: .any).matching(predicate).firstMatch,
            ]
            for overflow in candidates where overflow.waitForExistence(timeout: 3) {
                overflow.tap()
                if tabSelectionMarker(for: label).waitForExistence(timeout: 3) {
                    return
                }
            }
        }
        XCTFail("Could not select tab '\(label)' (id: \(identifier))")
    }

    private func tabSelectionMarker(for label: String) -> XCUIElement {
        switch label {
        case "Programs":
            return app.staticTexts["Scholar Workspace"]
        case "Finance AI":
            return app.staticTexts["Finance AI Console"]
        case "Legal AI":
            return app.staticTexts["Legal DeepSeek Sub-Agent"]
        case "Agents":
            return app.navigationBars["Agents"]
        case "Blueprint":
            return app.staticTexts["WCS Platform Blueprint"]
        case "Approvals":
            return app.navigationBars["Approvals"]
        default:
            return app.navigationBars[label]
        }
    }

    private func scrollToElement(_ element: XCUIElement, swipes: Int = 8, timeout: TimeInterval = 1) -> Bool {
        if element.waitForExistence(timeout: timeout) {
            return true
        }

        for _ in 0..<swipes {
            app.swipeUp()
            if element.waitForExistence(timeout: timeout) {
                return true
            }
        }
        return element.exists
    }

    private func scrollToStaticText(_ text: String, swipes: Int = 8, timeout: TimeInterval = 1) -> Bool {
        scrollToElement(app.staticTexts[text], swipes: swipes, timeout: timeout)
    }

    @MainActor
    func testProgramsTabAndHealthUX() throws {
        tapTab(identifier: "tab.programs", label: "Programs")

        XCTAssertTrue(app.navigationBars["World Class Scholars"].waitForExistence(timeout: 8))
        XCTAssertTrue(app.staticTexts["Scholar Workspace"].waitForExistence(timeout: 8))
    }

    @MainActor
    func testAgentsAndApprovalsTabs() throws {
        tapTab(identifier: "tab.agents", label: "Agents")
        XCTAssertTrue(app.navigationBars["Agents"].waitForExistence(timeout: 8))

        tapTab(identifier: "tab.approvals", label: "Approvals")
        XCTAssertTrue(app.navigationBars["Approvals"].waitForExistence(timeout: 8))
    }

    @MainActor
    func testFinanceAIOverviewLoadsCriticalMetricsAndAppearance() throws {
        tapTab(identifier: "tab.financeAI", label: "Finance AI")

        XCTAssertTrue(app.navigationBars["Overview"].waitForExistence(timeout: 8))
        XCTAssertTrue(app.staticTexts["Finance AI Console"].waitForExistence(timeout: 8))
        XCTAssertTrue(app.staticTexts["Inbox"].waitForExistence(timeout: 8))
        XCTAssertTrue(app.staticTexts["Approval gates"].waitForExistence(timeout: 8))
        XCTAssertTrue(app.staticTexts["Compliance"].waitForExistence(timeout: 8))
        XCTAssertTrue(app.staticTexts["Posted value"].waitForExistence(timeout: 8))

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Finance AI Overview"
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    @MainActor
    func testLegalDeepSeekOverviewLoadsPromptMetricsAndSafeguards() throws {
        tapTab(identifier: "tab.legalAI", label: "Legal AI")

        XCTAssertTrue(app.staticTexts["Legal DeepSeek Sub-Agent"].waitForExistence(timeout: 8))
        XCTAssertTrue(app.staticTexts["Matters"].waitForExistence(timeout: 8))
        XCTAssertTrue(app.staticTexts["Review gates"].waitForExistence(timeout: 8))
        XCTAssertTrue(app.staticTexts["High risks"].waitForExistence(timeout: 8))
        XCTAssertTrue(app.staticTexts["Prompt packs"].waitForExistence(timeout: 8))
    }

    @MainActor
    func testBlueprintPerformanceMonitorLoadsPortfolioSignals() throws {
        tapTab(identifier: "tab.blueprint", label: "Blueprint")

        XCTAssertTrue(app.staticTexts["WCS Platform Blueprint"].waitForExistence(timeout: 8))
        XCTAssertTrue(app.staticTexts["Post-launch portfolio monitor"].waitForExistence(timeout: 8))
        XCTAssertTrue(app.staticTexts["Zero-rating apps"].waitForExistence(timeout: 8))
        XCTAssertTrue(scrollToStaticText("Monitoring engine outputs"))
        XCTAssertTrue(scrollToStaticText("Installed monitoring engines"))
        XCTAssertTrue(scrollToStaticText("Weekly scorecard engine"))
        XCTAssertTrue(scrollToStaticText("AgedCare Monitor", swipes: 10))
    }

    @MainActor
    func testFinanceAIBackendCommandsGenerateReport() throws {
        tapTab(identifier: "tab.financeAI", label: "Finance AI")
        XCTAssertTrue(app.navigationBars["Overview"].waitForExistence(timeout: 8))

        let sync = app.buttons["finance.syncButton"]
        XCTAssertTrue(sync.waitForExistence(timeout: 8))
        sync.tap()
        XCTAssertTrue(app.staticTexts["finance.backendMessage"].waitForExistence(timeout: 8))

        let generate = app.buttons["finance.generateReportButton"]
        XCTAssertTrue(generate.waitForExistence(timeout: 8))
        generate.tap()

        XCTAssertTrue(app.navigationBars["Reports"].waitForExistence(timeout: 8))
        XCTAssertTrue(app.staticTexts["AI generated finance brief"].waitForExistence(timeout: 8))
        XCTAssertTrue(app.staticTexts["Generated from the governed finance workspace for World Class Scholars review."].waitForExistence(timeout: 8))
    }

    @MainActor
    func testFinanceAILiveBackendCommandsGenerateGovernanceReport() throws {
        guard shouldRunLiveBackendTest else {
            throw XCTSkip("Live backend UI test requires WCS_RUN_LIVE_BACKEND_UI_TESTS=1 or /tmp/wcs-live-backend-base-url.")
        }

        tapTab(identifier: "tab.financeAI", label: "Finance AI")
        XCTAssertTrue(app.navigationBars["Overview"].waitForExistence(timeout: 12))

        let sync = app.buttons["finance.syncButton"]
        XCTAssertTrue(sync.waitForExistence(timeout: 12))
        sync.tap()
        XCTAssertTrue(app.staticTexts["finance.backendMessage"].waitForExistence(timeout: 12))

        let generate = app.buttons["finance.generateReportButton"]
        XCTAssertTrue(generate.waitForExistence(timeout: 12))
        generate.tap()
        if !app.navigationBars["Reports"].waitForExistence(timeout: 12),
           generate.waitForExistence(timeout: 4)
        {
            app.tap()
            generate.tap()
        }

        XCTAssertTrue(app.navigationBars["Reports"].waitForExistence(timeout: 18))
        XCTAssertTrue(app.staticTexts["AI generated finance and governance brief"].waitForExistence(timeout: 12))
        XCTAssertTrue(app.staticTexts["The governed backend prepared a board-ready view across ledger, compliance, grants, and approvals."].waitForExistence(timeout: 12))
    }

    @MainActor
    func testAgentsFormAcceptsTextAndExposesRunAction() throws {
        tapTab(identifier: "tab.agents", label: "Agents")
        XCTAssertTrue(app.navigationBars["Agents"].waitForExistence(timeout: 8))

        let email = app.textFields["agents.participantEmail"]
        XCTAssertTrue(email.waitForExistence(timeout: 8))
        email.tap()
        email.typeText(XCUIKeyboardKey.delete.rawValue)
        email.typeText("tester@worldclassscholars.test")

        XCTAssertTrue(app.buttons["agents.runButton"].waitForExistence(timeout: 8))
    }

    @MainActor
    func testAppStoreScreenshotSet() throws {
        tapTab(identifier: "tab.programs", label: "Programs")
        XCTAssertTrue(app.staticTexts["Scholar Workspace"].waitForExistence(timeout: 8))
        captureDistributionScreenshot("01-scholar-workspace")

        tapTab(identifier: "tab.financeAI", label: "Finance AI")
        XCTAssertTrue(app.staticTexts["Finance AI Console"].waitForExistence(timeout: 8))
        captureDistributionScreenshot("02-finance-ai-console")

        let generate = app.buttons["finance.generateReportButton"]
        XCTAssertTrue(generate.waitForExistence(timeout: 8))
        generate.tap()
        XCTAssertTrue(app.navigationBars["Reports"].waitForExistence(timeout: 8))
        XCTAssertTrue(app.staticTexts["AI generated finance brief"].waitForExistence(timeout: 8))
        captureDistributionScreenshot("03-board-reporting")

        tapTab(identifier: "tab.agents", label: "Agents")
        XCTAssertTrue(app.navigationBars["Agents"].waitForExistence(timeout: 8))
        captureDistributionScreenshot("04-agent-commands")
    }

    private func captureDistributionScreenshot(_ name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    @MainActor
    func testLaunchPerformance() throws {
        #if targetEnvironment(simulator)
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            let a = XCUIApplication()
            a.launchArguments = ["--uitesting"]
            a.launch()
        }
        #else
        throw XCTSkip("Launch performance metrics are collected on simulator in this suite; physical-device runs cover functional flows.")
        #endif
    }
}

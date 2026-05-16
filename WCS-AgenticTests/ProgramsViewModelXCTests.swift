//
//  ProgramsViewModelXCTests.swift
//  WCS-AgenticTests
//

import XCTest
@testable import WCS_Agentic

final class ProgramsViewModelXCTests: XCTestCase {
    @MainActor
    func testRefreshHealthUsesMockAPI() async {
        let vm = ProgramsViewModel(api: MockBackendClient(healthBody: "alive"))
        await vm.refreshHealth()
        XCTAssertEqual(vm.lastHealth, "alive")
        XCTAssertNil(vm.lastError)
    }
}

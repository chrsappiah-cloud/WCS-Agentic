//
//  BackendClientXCTests.swift
//  WCS-AgenticTests
//

import XCTest
@testable import WCS_Agentic

final class BackendClientXCTests: XCTestCase {
    func testMockHealth() async throws {
        let client = MockBackendClient(healthBody: "ok")
        let h = try await client.health()
        XCTAssertEqual(h, "ok")
    }

    func testMockCreateParticipantReturnsConfiguredUUID() async throws {
        let id = UUID(uuidString: "AAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE")!
        var client = MockBackendClient()
        client.nextParticipantID = id
        let out = try await client.createParticipant(email: "a@b.c", fullName: "A B")
        XCTAssertEqual(out, id)
    }
}

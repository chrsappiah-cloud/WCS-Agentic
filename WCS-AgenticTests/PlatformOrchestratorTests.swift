//
//  PlatformOrchestratorTests.swift
//  WCS-AgenticTests
//

import Testing
@testable import WCS_Agentic

struct PlatformOrchestratorTests {
    @Test func mockOnboardingQueuesApproval() async throws {
        let mock = MockPlatformOrchestratorClient()
        let res = try await mock.startOnboarding(
            participantEmail: "test@example.com",
            documentHint: "passport",
            fullName: nil,
            role: "operator"
        )
        #expect(!res.sessionId.isEmpty)
        let pending = try await mock.listPendingApprovals()
        #expect(!pending.isEmpty)
    }

    @Test func mockKillSwitch() async throws {
        let mock = MockPlatformOrchestratorClient()
        let on = try await mock.setKillSwitch(enabled: true)
        #expect(on.killSwitch == true)
        let off = try await mock.setKillSwitch(enabled: false)
        #expect(off.killSwitch == false)
    }
}

//
//  LegalDeepSeekWorkspaceTests.swift
//  WCS-AgenticTests
//

import XCTest
@testable import WCS_Agentic

@MainActor
final class LegalDeepSeekWorkspaceTests: XCTestCase {
    private var workspace: LegalDeepSeekWorkspace!

    override func setUp() {
        super.setUp()
        workspace = LegalDeepSeekWorkspace()
    }

    override func tearDown() {
        workspace = nil
        super.tearDown()
    }

    func testPromptLibraryCoversPastedDeepSeekLegalPracticeAreas() {
        let areas = Set(LegalDeepSeekPromptLibrary.templates.map(\.practiceArea))

        XCTAssertTrue(areas.contains(.contractAnalysis))
        XCTAssertTrue(areas.contains(.litigationStrategy))
        XCTAssertTrue(areas.contains(.complianceRisk))
        XCTAssertTrue(areas.contains(.legalWriting))
        XCTAssertTrue(areas.contains(.clientConsultation))
        XCTAssertTrue(areas.contains(.lawFirmMarketing))
        XCTAssertTrue(areas.contains(.legalInnovation))
        XCTAssertEqual(LegalDeepSeekPromptLibrary.templates.count, 7)
    }

    func testGuardrailsRequireHumanLawyerReviewAndCitationVerification() {
        let guardrails = [
            LegalDeepSeekPromptLibrary.systemGuardrails,
            LegalDeepSeekPromptLibrary.developerGuardrails,
        ].joined(separator: "\n")

        XCTAssertTrue(guardrails.localizedCaseInsensitiveContains("not a lawyer"))
        XCTAssertTrue(guardrails.localizedCaseInsensitiveContains("lawyer approves"))
        XCTAssertTrue(guardrails.localizedCaseInsensitiveContains("citation verification"))
        XCTAssertTrue(guardrails.localizedCaseInsensitiveContains("local or self-hosted"))
    }

    func testRunningContractReviewCreatesLawyerReviewGateAndAuditEvent() {
        workspace.setPracticeArea(.contractAnalysis)
        let initialAuditCount = workspace.auditTrail.count

        let review = workspace.runSelectedReview(actor: "unit.legal@worldclassscholars.test")

        XCTAssertNotNil(review)
        XCTAssertEqual(workspace.reviews.count, 1)
        XCTAssertEqual(workspace.reviews.first?.status, .lawyerReviewRequired)
        XCTAssertTrue(workspace.reviews.first?.humanReviewRequired == true)
        XCTAssertEqual(workspace.auditTrail.count, initialAuditCount + 1)
        XCTAssertEqual(workspace.auditTrail.first?.actor, "unit.legal@worldclassscholars.test")
    }

    func testCloudPrototypeWithConfidentialMatterIsBlockedByEngine() {
        let matter = LegalMatter(
            id: UUID(),
            name: "Privileged cloud test",
            clientReference: "TEST",
            jurisdiction: "Australia",
            practiceArea: .contractAnalysis,
            confidentialityLevel: "Privileged and confidential",
            facts: "Review an agreement containing client-sensitive facts.",
            objective: "Identify risk.",
            sourceIds: [],
            reviewStatus: .draft
        )
        let engine = LegalDeepSeekEngine(runtimeMode: .cloudPrototype)

        let review = engine.draftReview(
            for: matter,
            template: LegalDeepSeekPromptLibrary.templates[0],
            evidence: []
        )

        XCTAssertEqual(review.status, .blocked)
        XCTAssertTrue(review.findings.contains { $0.title.localizedCaseInsensitiveContains("Confidential data") })
    }

    func testInvocationContainsMatterEvidenceAndOutputContract() {
        let matter = workspace.matters.first!
        let invocation = workspace.buildInvocation(for: matter)

        XCTAssertTrue(invocation.system.contains("Legal DeepSeek"))
        XCTAssertTrue(invocation.user.contains(matter.name))
        XCTAssertTrue(invocation.user.contains(matter.jurisdiction))
        XCTAssertTrue(invocation.user.contains("Evidence:"))
        XCTAssertTrue(invocation.outputContract.contains("lawyer approval gate"))
    }

    func testLawyerApprovalMovesMatterAndReviewToApproved() {
        workspace.setPracticeArea(.contractAnalysis)
        guard let review = workspace.runSelectedReview() else {
            XCTFail("Expected review")
            return
        }

        workspace.approve(review, actor: "counsel@test.wcs")

        XCTAssertEqual(workspace.reviews.first?.status, .approved)
        XCTAssertEqual(workspace.matters.first { $0.id == review.matterId }?.reviewStatus, .approved)
        XCTAssertEqual(workspace.auditTrail.first?.actor, "counsel@test.wcs")
    }
}

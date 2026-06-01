//
//  FinanceAgentWorkspaceTests.swift
//  WCS-AgenticTests
//

import XCTest
@testable import WCS_Agentic

@MainActor
final class FinanceAgentWorkspaceTests: XCTestCase {
    private var workspace: FinanceAgentWorkspace!

    override func setUp() {
        super.setUp()
        workspace = FinanceAgentWorkspace()
    }

    override func tearDown() {
        workspace = nil
        super.tearDown()
    }

    func testZeroSuiteWiringCreatesFreshWorkspace() {
        XCTAssertNotNil(workspace)
    }

    func testDemoWorkspaceHasGovernedOperatingData() {
        XCTAssertFalse(workspace.records.isEmpty)
        XCTAssertFalse(workspace.complianceTasks.isEmpty)
        XCTAssertFalse(workspace.governanceEvents.isEmpty)
        XCTAssertFalse(workspace.grants.isEmpty)
        XCTAssertEqual(FinanceAgentPromptLibrary.templates.count, 4)
        XCTAssertGreaterThan(workspace.approvalRequiredCount, 0)
    }

    func testApprovalMutationEmitsAuditEvent() {
        let record = workspace.inboxRecords.first!
        let initialAuditCount = workspace.auditTrail.count

        workspace.approve(record, actor: "unit.test@worldclassscholars.test")

        XCTAssertEqual(workspace.auditTrail.count, initialAuditCount + 1)
        XCTAssertEqual(workspace.auditTrail.first?.actor, "unit.test@worldclassscholars.test")
        XCTAssertTrue(workspace.records.contains { $0.id == record.id && $0.status == .approved })
    }

    func testCriticalOrHighComplianceRaisesRisk() {
        XCTAssertEqual(workspace.complianceRisk, "At risk")
    }

    func testEscalatedAndLowConfidenceRecordsRequireHumanApproval() {
        let escalated = workspace.records.first { $0.status == .escalated }
        let lowConfidence = workspace.records.first { $0.confidence < 0.86 }

        XCTAssertTrue(escalated?.requiresHumanApproval == true)
        XCTAssertTrue(lowConfidence?.requiresHumanApproval == true)
    }

    func testHighConfidenceOrdinaryInvoiceDoesNotRequireHumanApproval() {
        let invoice = workspace.records.first {
            $0.documentType == "Supplier invoice" && $0.confidence >= 0.86
        }

        XCTAssertEqual(invoice?.requiresHumanApproval, false)
    }

    func testPostApprovedRecordMovesValueIntoPostedTotal() {
        let record = workspace.inboxRecords.first { $0.confidence >= 0.86 }!

        XCTAssertEqual(workspace.postedTotal, Decimal(0))
        workspace.approve(record)
        workspace.post(record)

        XCTAssertEqual(workspace.records.first { $0.id == record.id }?.status, .posted)
        XCTAssertEqual(workspace.postedTotal, record.amount.amount)
    }

    func testCompletingComplianceTaskLowersRiskWhenHighTaskIsDone() {
        let high = workspace.complianceTasks.first { $0.severity == .high }!

        workspace.complete(high)

        XCTAssertEqual(workspace.complianceTasks.first { $0.id == high.id }?.status, .completed)
        XCTAssertEqual(workspace.complianceRisk, "On track")
    }

    func testPromptTemplatesExposeStrictOutputContracts() {
        let contracts = FinanceAgentPromptLibrary.templates.map(\.outputContract).joined(separator: "\n")

        XCTAssertTrue(contracts.contains("JSON"))
        XCTAssertTrue(contracts.contains("Markdown"))
        XCTAssertTrue(contracts.contains("APPROVE"))
        XCTAssertTrue(contracts.contains("NEEDS_REVIEW"))
    }

    func testGrantMilestoneContainsEvidenceAndTrancheControls() {
        let milestone = workspace.grants.first?.milestones.first

        XCTAssertEqual(milestone?.title, "Milestone 2 acquittal pack")
        XCTAssertFalse(milestone?.requiredEvidence.isEmpty ?? true)
        XCTAssertEqual(milestone?.trancheAmount?.currency, "AUD")
    }

    func testGovernanceApprovalNoteWritesExplainabilityAuditTrail() {
        let event = workspace.governanceEvents.first!
        let initialAuditCount = workspace.auditTrail.count

        workspace.addBoardApprovalNote(for: event, actor: "secretary@test.wcs")

        XCTAssertEqual(workspace.auditTrail.count, initialAuditCount + 1)
        XCTAssertEqual(workspace.auditTrail.first?.actor, "secretary@test.wcs")
        XCTAssertEqual(workspace.auditTrail.first?.object, event.eventType)
    }
}

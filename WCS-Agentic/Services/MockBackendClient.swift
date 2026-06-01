//
//  MockBackendClient.swift
//  WCS-Agentic
//

import Foundation

/// Deterministic backend for SwiftUI previews, UI tests, and offline demos.
struct MockBackendClient: APIServing {
    var healthBody: String = "ok"
    var nextParticipantID: UUID = UUID(uuidString: "00000000-0000-4000-8000-000000000001")!
    private let financeSeed = FinanceAgentSeed.demo

    func health() async throws -> String {
        healthBody
    }

    func createParticipant(email: String, fullName: String) async throws -> UUID {
        _ = email
        _ = fullName
        return nextParticipantID
    }

    func uploadIdentity(participantID: UUID, documentURL: String) async throws {
        _ = participantID
        _ = documentURL
    }

    func approveWorkflow(workflowID: UUID, approvedBy: String) async throws {
        _ = workflowID
        _ = approvedBy
    }

    func fetchFinanceSnapshot() async throws -> FinanceWorkspaceSnapshot {
        snapshot(from: financeSeed)
    }

    func updateAccountingRecordStatus(id: UUID, status: RecordStatus, actor: String) async throws -> FinanceWorkspaceSnapshot {
        _ = id
        _ = status
        _ = actor
        return snapshot(from: financeSeed)
    }

    func completeComplianceTask(id: UUID, actor: String) async throws -> FinanceWorkspaceSnapshot {
        _ = id
        _ = actor
        return snapshot(from: financeSeed)
    }

    func captureGovernanceApprovalNote(id: UUID, actor: String) async throws -> FinanceWorkspaceSnapshot {
        _ = id
        _ = actor
        return snapshot(from: financeSeed)
    }

    func generateFinanceReport(period: String, actor: String) async throws -> GeneratedReportResponse {
        _ = actor
        let report = FinanceReport(
            id: UUID(),
            title: "AI generated finance brief",
            period: period,
            sections: [
                ReportSection(
                    id: UUID(),
                    heading: "Executive overview",
                    body: "Generated from the governed finance workspace for UI testing.",
                    evidenceRefs: financeSeed.evidence.map(\.fileName)
                ),
            ],
            decisionsRequired: ["Review exceptions before external release."]
        )
        return GeneratedReportResponse(
            report: report,
            auditEvent: AuditEvent(
                id: UUID(),
                timestamp: .now,
                actor: actor,
                action: "Generated report",
                object: report.title,
                rationale: "Mock backend report generation completed."
            )
        )
    }

    private func snapshot(from seed: FinanceAgentSeed) -> FinanceWorkspaceSnapshot {
        FinanceWorkspaceSnapshot(
            evidence: seed.evidence,
            records: seed.records,
            complianceTasks: seed.complianceTasks,
            governanceEvents: seed.governanceEvents,
            grants: seed.grants,
            auditTrail: seed.auditTrail,
            policyPacks: seed.policyPacks,
            reports: seed.reports
        )
    }
}

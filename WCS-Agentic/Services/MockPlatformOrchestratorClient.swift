//
//  MockPlatformOrchestratorClient.swift
//  WCS-Agentic
//

import Foundation

final class MockPlatformOrchestratorClient: PlatformOrchestrating, @unchecked Sendable {
    var killSwitch = false
    var pendingApprovals: [ApprovalItemDTO] = []

    func health() async throws -> OrchestratorHealth {
        OrchestratorHealth(status: "ok", killSwitch: killSwitch)
    }

    func setKillSwitch(enabled: Bool) async throws -> OrchestratorHealth {
        killSwitch = enabled
        return OrchestratorHealth(status: "ok", killSwitch: killSwitch)
    }

    func startOnboarding(
        participantEmail: String,
        documentHint: String,
        fullName: String?,
        role: String
    ) async throws -> WorkflowStartResponse {
        _ = documentHint
        _ = fullName
        _ = role
        let id = UUID().uuidString
        pendingApprovals.append(
            ApprovalItemDTO(
                id: UUID().uuidString,
                sessionId: id,
                status: "pending",
                payload: ApprovalPayloadDTO(
                    type: "onboarding_review",
                    email: participantEmail,
                    message: "Mock approval for UI tests",
                    participantId: nil,
                    courseId: nil
                ),
                createdAt: ISO8601DateFormatter().string(from: .now)
            )
        )
        return WorkflowStartResponse(sessionId: id, status: "started")
    }

    func startCertificate(participantId: UUID, courseId: String, role: String) async throws -> WorkflowStartResponse {
        _ = participantId
        _ = courseId
        _ = role
        return WorkflowStartResponse(sessionId: UUID().uuidString, status: "started")
    }

    func startConcierge(participantId: UUID, role: String) async throws -> WorkflowStartResponse {
        _ = participantId
        _ = role
        return WorkflowStartResponse(sessionId: UUID().uuidString, status: "started")
    }

    func fetchSession(id: String) async throws -> WorkflowSessionDTO {
        WorkflowSessionDTO(
            id: id,
            workflowType: "onboarding",
            status: "awaiting_approval",
            tokensUsed: 520,
            nodes: [
                WorkflowNodeDTO(node: "email_confirm", status: "simulated_ok", at: nil),
                WorkflowNodeDTO(node: "id_extract", status: "ok", at: nil),
            ],
            result: SessionResultDTO(status: "awaiting_approval", approvalId: pendingApprovals.first?.id, participantId: nil, recommendations: nil),
            error: nil
        )
    }

    func listPendingApprovals() async throws -> [ApprovalItemDTO] {
        pendingApprovals.filter { $0.status == "pending" }
    }

    func approve(id: String, approvedBy: String) async throws {
        _ = approvedBy
        pendingApprovals.removeAll { $0.id == id }
    }

    func deny(id: String, reason: String) async throws {
        _ = reason
        pendingApprovals.removeAll { $0.id == id }
    }

    func fetchAudit(limit: Int) async throws -> [AuditEventDTO] {
        [
            AuditEventDTO(
                sessionId: "mock",
                type: "session_created",
                detail: AuditDetailDTO(workflowType: "onboarding", approvalId: nil, enabled: nil, error: nil, by: nil),
                at: ISO8601DateFormatter().string(from: .now)
            ),
        ]
        .suffix(limit)
        .map { $0 }
    }
}

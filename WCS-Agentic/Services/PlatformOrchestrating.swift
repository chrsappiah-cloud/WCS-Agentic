//
//  PlatformOrchestrating.swift
//  WCS-Agentic
//

import Foundation

/// Node orchestrator API (`platform/orchestrator`).
protocol PlatformOrchestrating: Sendable {
    func health() async throws -> OrchestratorHealth
    func setKillSwitch(enabled: Bool) async throws -> OrchestratorHealth
    func startOnboarding(participantEmail: String, documentHint: String, fullName: String?, role: String) async throws -> WorkflowStartResponse
    func startCertificate(participantId: UUID, courseId: String, role: String) async throws -> WorkflowStartResponse
    func startConcierge(participantId: UUID, role: String) async throws -> WorkflowStartResponse
    func fetchSession(id: String) async throws -> WorkflowSessionDTO
    func listPendingApprovals() async throws -> [ApprovalItemDTO]
    func approve(id: String, approvedBy: String) async throws
    func deny(id: String, reason: String) async throws
    func fetchAudit(limit: Int) async throws -> [AuditEventDTO]
}

struct OrchestratorHealth: Decodable, Equatable, Sendable {
    let status: String
    let killSwitch: Bool
}

struct WorkflowStartResponse: Decodable, Sendable {
    let sessionId: String
    let status: String
}

struct WorkflowSessionDTO: Decodable, Sendable {
    let id: String
    let workflowType: String
    let status: String
    let tokensUsed: Int?
    let nodes: [WorkflowNodeDTO]?
    let result: SessionResultDTO?
    let error: String?
}

struct WorkflowNodeDTO: Decodable, Sendable {
    let node: String?
    let status: String?
    let at: String?
}

struct SessionResultDTO: Decodable, Sendable {
    let status: String?
    let approvalId: String?
    let participantId: String?
    let recommendations: [ConciergeRecommendationDTO]?
}

struct ConciergeRecommendationDTO: Decodable, Sendable {
    let moduleId: String?
    let score: Double?
    let reason: String?
}

struct ApprovalsListResponse: Decodable, Sendable {
    let items: [ApprovalItemDTO]
}

struct ApprovalItemDTO: Decodable, Identifiable, Sendable {
    let id: String
    let sessionId: String
    let status: String
    let payload: ApprovalPayloadDTO?
    let createdAt: String?
}

struct ApprovalPayloadDTO: Decodable, Sendable {
    let type: String?
    let email: String?
    let message: String?
    let participantId: String?
    let courseId: String?
}

struct AuditLogResponse: Decodable, Sendable {
    let events: [AuditEventDTO]
}

struct AuditEventDTO: Decodable, Identifiable, Sendable {
    var id: String { "\(sessionId)-\(at)-\(type)" }
    let sessionId: String
    let type: String
    let detail: AuditDetailDTO?
    let at: String
}

struct AuditDetailDTO: Decodable, Sendable {
    let workflowType: String?
    let approvalId: String?
    let enabled: Bool?
    let error: String?
    let by: String?
}

enum PlatformError: Error, LocalizedError {
    case invalidURL
    case badStatus(Int)
    case decoding
    case killSwitchActive

    var errorDescription: String? {
        switch self {
        case .invalidURL: "Invalid orchestrator URL"
        case .badStatus(let code): "Orchestrator returned status \(code)"
        case .decoding: "Could not decode orchestrator response"
        case .killSwitchActive: "Platform kill-switch is active"
        }
    }
}

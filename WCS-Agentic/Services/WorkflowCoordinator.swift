//
//  WorkflowCoordinator.swift
//  WCS-Agentic
//

import Combine
import Foundation
import SwiftData

@MainActor
final class WorkflowCoordinator: ObservableObject {
    @Published private(set) var orchestratorHealth = "—"
    @Published private(set) var killSwitchActive = false
    @Published private(set) var pendingApprovals: [ApprovalItemDTO] = []
    @Published private(set) var auditEvents: [AuditEventDTO] = []
    @Published private(set) var lastError: String?
    @Published private(set) var isBusy = false

    private let platform: PlatformOrchestrating

    init(platform: PlatformOrchestrating) {
        self.platform = platform
    }

    func refreshPlatformStatus() async {
        isBusy = true
        lastError = nil
        defer { isBusy = false }
        do {
            let h = try await platform.health()
            orchestratorHealth = h.status
            killSwitchActive = h.killSwitch
        } catch {
            orchestratorHealth = "unavailable"
            lastError = error.localizedDescription
        }
    }

    func refreshApprovals() async {
        do {
            pendingApprovals = try await platform.listPendingApprovals()
        } catch {
            lastError = error.localizedDescription
        }
    }

    func refreshAudit() async {
        do {
            auditEvents = try await platform.fetchAudit(limit: 40)
        } catch {
            lastError = error.localizedDescription
        }
    }

    func setKillSwitch(_ enabled: Bool) async {
        isBusy = true
        defer { isBusy = false }
        do {
            let h = try await platform.setKillSwitch(enabled: enabled)
            killSwitchActive = h.killSwitch
            orchestratorHealth = h.status
        } catch {
            lastError = error.localizedDescription
        }
    }

    func approve(_ item: ApprovalItemDTO, approvedBy: String) async {
        do {
            try await platform.approve(id: item.id, approvedBy: approvedBy)
            await refreshApprovals()
        } catch {
            lastError = error.localizedDescription
        }
    }

    func deny(_ item: ApprovalItemDTO, reason: String) async {
        do {
            try await platform.deny(id: item.id, reason: reason)
            await refreshApprovals()
        } catch {
            lastError = error.localizedDescription
        }
    }

    @discardableResult
    func startProductionWorkflow(
        agent: AgentKind,
        participantEmail: String,
        documentHint: String,
        participantId: UUID?,
        courseId: String,
        role: String,
        initiatedBy: String,
        sessions: WorkflowSessionRepository,
        monitoring: MonitoringRepository
    ) async throws -> WorkflowSessionRecord {
        let response: WorkflowStartResponse
        switch agent {
        case .onboarding:
            response = try await platform.startOnboarding(
                participantEmail: participantEmail,
                documentHint: documentHint,
                fullName: nil,
                role: role
            )
        case .certificate:
            guard let participantId else { throw PlatformError.decoding }
            response = try await platform.startCertificate(
                participantId: participantId,
                courseId: courseId,
                role: role
            )
        case .concierge:
            guard let participantId else { throw PlatformError.decoding }
            response = try await platform.startConcierge(participantId: participantId, role: role)
        case .support, .campaign:
            throw PlatformError.badStatus(501)
        }

        let session = try await platform.fetchSession(id: response.sessionId)
        let record = WorkflowSessionRecord(
            platformSessionId: response.sessionId,
            workflowType: agent.workflowType,
            status: session.status,
            summary: "Started \(agent.rawValue) — session \(response.sessionId.prefix(8))…",
            initiatedByEmail: initiatedBy
        )
        try sessions.insert(record)
        try monitoring.log(
            source: "Orchestrator.\(agent.workflowType)",
            message: "Workflow started: \(response.sessionId)",
            severity: .info
        )
        await refreshApprovals()
        return record
    }
}

private extension AgentKind {
    var workflowType: String {
        switch self {
        case .onboarding: "onboarding"
        case .certificate: "certificate"
        case .concierge: "concierge"
        case .support: "support"
        case .campaign: "campaign"
        }
    }
}

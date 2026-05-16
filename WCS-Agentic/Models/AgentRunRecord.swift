//
//  AgentRunRecord.swift
//  WCS-Agentic
//

import Foundation
import SwiftData

enum AgentKind: String, Codable, CaseIterable, Sendable {
    case onboarding = "Onboarding"
    case concierge = "Learning Concierge"
    case certificate = "Certificate Prep"
    case support = "Support Triage"
    case campaign = "Campaign Draft"

    var systemImage: String {
        switch self {
        case .onboarding: "person.badge.plus"
        case .concierge: "map"
        case .support: "lifepreserver"
        case .certificate: "checkmark.seal"
        case .campaign: "megaphone"
        }
    }

    var description: String {
        switch self {
        case .onboarding:
            "Production flow: email → ID extract → human approval → participant create (orchestrator)."
        case .concierge:
            "Module recommendations and nudges—read-only, token-capped (orchestrator stub)."
        case .support:
            "Classify tickets, suggest replies, escalate safety issues (local supervised draft)."
        case .certificate:
            "Deterministic prep → dual-control approval queue; never auto-issue."
        case .campaign:
            "Draft assets with citations; queue for editorial review (local supervised draft)."
        }
    }

    /// Routed to `platform/orchestrator` when true.
    var usesPlatformOrchestrator: Bool {
        switch self {
        case .onboarding, .certificate, .concierge: true
        case .support, .campaign: false
        }
    }
}

@Model
final class AgentRunRecord {
    @Attribute(.unique) var id: UUID
    var agentKindRaw: String
    var prompt: String
    var response: String
    var status: String
    var initiatedByEmail: String
    var createdAt: Date

    var agentKind: AgentKind {
        get { AgentKind(rawValue: agentKindRaw) ?? .onboarding }
        set { agentKindRaw = newValue.rawValue }
    }

    init(
        id: UUID = UUID(),
        agentKind: AgentKind,
        prompt: String,
        response: String = "",
        status: String = "queued",
        initiatedByEmail: String,
        createdAt: Date = .now
    ) {
        self.id = id
        self.agentKindRaw = agentKind.rawValue
        self.prompt = prompt
        self.response = response
        self.status = status
        self.initiatedByEmail = initiatedByEmail
        self.createdAt = createdAt
    }
}

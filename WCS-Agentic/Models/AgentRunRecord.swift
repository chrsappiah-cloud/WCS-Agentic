//
//  AgentRunRecord.swift
//  WCS-Agentic
//

import Foundation
import SwiftData

enum AgentKind: String, Codable, CaseIterable, Sendable {
    case onboarding = "Onboarding"
    case support = "Support Triage"
    case certificate = "Certificate Prep"
    case campaign = "Campaign Draft"

    var systemImage: String {
        switch self {
        case .onboarding: "person.badge.plus"
        case .support: "lifepreserver"
        case .certificate: "checkmark.seal"
        case .campaign: "megaphone"
        }
    }

    var description: String {
        switch self {
        case .onboarding:
            "Intake profile, verify email, route ID edge cases to human review."
        case .support:
            "Classify tickets, suggest replies, escalate safety issues."
        case .certificate:
            "Prepare issuance payload; never auto-issue without approval."
        case .campaign:
            "Draft assets with citations; queue for editorial review."
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

//
//  UserRole.swift
//  WCS-Agentic
//

import Foundation

enum UserRole: String, Codable, CaseIterable, Sendable {
    case user
    case operatorRole = "operator"
    case admin

    var displayName: String {
        switch self {
        case .user: "User"
        case .operatorRole: "Operator"
        case .admin: "Admin"
        }
    }

    var canAccessAdminPanel: Bool {
        self == .admin
    }

    var canRunAgents: Bool {
        self == .admin || self == .operatorRole
    }
}

enum SubscriptionTier: String, Codable, CaseIterable, Sendable {
    case free
    case trial
    case pro

    var displayName: String {
        switch self {
        case .free: "Free"
        case .trial: "Trial"
        case .pro: "Pro"
        }
    }

    var allowsAgentAutomation: Bool {
        self == .trial || self == .pro
    }
}

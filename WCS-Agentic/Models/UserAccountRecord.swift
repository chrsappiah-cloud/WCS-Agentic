//
//  UserAccountRecord.swift
//  WCS-Agentic
//

import Foundation
import SwiftData

@Model
final class UserAccountRecord {
    @Attribute(.unique) var id: UUID
    var email: String
    var displayName: String
    var roleRaw: String
    var subscriptionTierRaw: String
    var isAccessEnabled: Bool
    var createdAt: Date
    var updatedAt: Date

    var role: UserRole {
        get { UserRole(rawValue: roleRaw) ?? .user }
        set { roleRaw = newValue.rawValue }
    }

    var subscriptionTier: SubscriptionTier {
        get { SubscriptionTier(rawValue: subscriptionTierRaw) ?? .free }
        set { subscriptionTierRaw = newValue.rawValue }
    }

    init(
        id: UUID = UUID(),
        email: String,
        displayName: String,
        role: UserRole = .user,
        subscriptionTier: SubscriptionTier = .free,
        isAccessEnabled: Bool = true,
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.email = email
        self.displayName = displayName
        self.roleRaw = role.rawValue
        self.subscriptionTierRaw = subscriptionTier.rawValue
        self.isAccessEnabled = isAccessEnabled
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

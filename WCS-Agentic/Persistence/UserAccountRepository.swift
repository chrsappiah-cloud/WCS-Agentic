//
//  UserAccountRepository.swift
//  WCS-Agentic
//

import Foundation
import SwiftData

@MainActor
final class UserAccountRepository {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func allUsers() throws -> [UserAccountRecord] {
        try modelContext.fetch(
            FetchDescriptor<UserAccountRecord>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
        )
    }

    func user(id: UUID) throws -> UserAccountRecord? {
        let fd = FetchDescriptor<UserAccountRecord>(predicate: #Predicate { $0.id == id })
        return try modelContext.fetch(fd).first
    }

    func user(email: String) throws -> UserAccountRecord? {
        let normalized = email.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        let fd = FetchDescriptor<UserAccountRecord>(predicate: #Predicate { $0.email == normalized })
        return try modelContext.fetch(fd).first
    }

    @discardableResult
    func upsert(email: String, displayName: String, role: UserRole = .user) throws -> UserAccountRecord {
        let normalized = email.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        if let existing = try user(email: normalized) {
            existing.displayName = displayName
            existing.updatedAt = .now
            try modelContext.save()
            return existing
        }
        let record = UserAccountRecord(email: normalized, displayName: displayName, role: role)
        modelContext.insert(record)
        try modelContext.save()
        return record
    }

    func setRole(id: UUID, role: UserRole) throws {
        guard let u = try user(id: id) else { return }
        u.role = role
        u.updatedAt = .now
        try modelContext.save()
    }

    func setSubscriptionTier(id: UUID, tier: SubscriptionTier) throws {
        guard let u = try user(id: id) else { return }
        u.subscriptionTier = tier
        u.updatedAt = .now
        try modelContext.save()
    }

    func setAccessEnabled(id: UUID, enabled: Bool) throws {
        guard let u = try user(id: id) else { return }
        u.isAccessEnabled = enabled
        u.updatedAt = .now
        try modelContext.save()
    }

    func seedDefaultsIfEmpty() throws {
        let users = try allUsers()
        guard users.isEmpty else { return }
        _ = try upsert(email: "admin@worldclassscholars.test", displayName: "WCS Admin", role: .admin)
        if let admin = try user(email: "admin@worldclassscholars.test") {
            admin.subscriptionTier = .pro
        }
        _ = try upsert(email: "operator@worldclassscholars.test", displayName: "WCS Operator", role: .operatorRole)
        _ = try upsert(email: "demo@worldclassscholars.test", displayName: "Demo User", role: .user)
        try modelContext.save()
    }
}

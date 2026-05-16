//
//  ParticipantRecord.swift
//  WCS-Agentic
//

import Foundation
import SwiftData

/// Local persistence for participant onboarding state (synced with Vapor backend when available).
@Model
final class ParticipantRecord {
    @Attribute(.unique) var id: UUID
    var email: String
    var fullName: String
    var status: String
    var createdAt: Date

    init(id: UUID = UUID(), email: String, fullName: String, status: String = "pending", createdAt: Date = .now) {
        self.id = id
        self.email = email
        self.fullName = fullName
        self.status = status
        self.createdAt = createdAt
    }
}

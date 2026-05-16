//
//  WorkflowSessionRecord.swift
//  WCS-Agentic
//

import Foundation
import SwiftData

@Model
final class WorkflowSessionRecord {
    @Attribute(.unique) var id: UUID
    var platformSessionId: String
    var workflowType: String
    var status: String
    var summary: String
    var initiatedByEmail: String
    var createdAt: Date

    init(
        id: UUID = UUID(),
        platformSessionId: String,
        workflowType: String,
        status: String,
        summary: String,
        initiatedByEmail: String,
        createdAt: Date = .now
    ) {
        self.id = id
        self.platformSessionId = platformSessionId
        self.workflowType = workflowType
        self.status = status
        self.summary = summary
        self.initiatedByEmail = initiatedByEmail
        self.createdAt = createdAt
    }
}

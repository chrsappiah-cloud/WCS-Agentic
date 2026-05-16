//
//  WorkflowRepository.swift
//  WCS-Agentic
//

import Foundation
import SwiftData

/// Database boundary: maps API results into SwiftData for offline-first UX.
@MainActor
final class WorkflowRepository {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func upsertParticipant(id: UUID, email: String, fullName: String, status: String = "synced") throws {
        let fd = FetchDescriptor<ParticipantRecord>(predicate: #Predicate { $0.id == id })
        if let existing = try modelContext.fetch(fd).first {
            existing.email = email
            existing.fullName = fullName
            existing.status = status
        } else {
            modelContext.insert(ParticipantRecord(id: id, email: email, fullName: fullName, status: status))
        }
        try modelContext.save()
    }

    func localParticipants() throws -> [ParticipantRecord] {
        try modelContext.fetch(FetchDescriptor<ParticipantRecord>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)]))
    }
}

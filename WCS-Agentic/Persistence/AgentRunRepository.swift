//
//  AgentRunRepository.swift
//  WCS-Agentic
//

import Foundation
import SwiftData

@MainActor
final class AgentRunRepository {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func recentRuns(limit: Int = 50) throws -> [AgentRunRecord] {
        var fd = FetchDescriptor<AgentRunRecord>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        fd.fetchLimit = limit
        return try modelContext.fetch(fd)
    }

    func insert(_ run: AgentRunRecord) throws {
        modelContext.insert(run)
        try modelContext.save()
    }

    func saveChanges() throws {
        try modelContext.save()
    }
}

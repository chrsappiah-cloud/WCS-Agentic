//
//  MonitoringRepository.swift
//  WCS-Agentic
//

import Foundation
import SwiftData

@MainActor
final class MonitoringRepository {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func recentEvents(limit: Int = 100) throws -> [MonitoringEventRecord] {
        var fd = FetchDescriptor<MonitoringEventRecord>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        fd.fetchLimit = limit
        return try modelContext.fetch(fd)
    }

    func log(source: String, message: String, severity: MonitoringSeverity = .info) throws {
        modelContext.insert(MonitoringEventRecord(source: source, message: message, severity: severity))
        try modelContext.save()
    }
}

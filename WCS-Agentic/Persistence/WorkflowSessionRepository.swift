//
//  WorkflowSessionRepository.swift
//  WCS-Agentic
//

import Foundation
import SwiftData

struct WorkflowSessionRepository {
    let modelContext: ModelContext

    func insert(_ record: WorkflowSessionRecord) throws {
        modelContext.insert(record)
        try modelContext.save()
    }

    func updateStatus(platformSessionId: String, status: String, summary: String) throws {
        let descriptor = FetchDescriptor<WorkflowSessionRecord>(
            predicate: #Predicate { $0.platformSessionId == platformSessionId }
        )
        guard let row = try modelContext.fetch(descriptor).first else { return }
        row.status = status
        row.summary = summary
        try modelContext.save()
    }
}

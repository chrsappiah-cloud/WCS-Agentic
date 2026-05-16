//
//  SwiftDataDatabaseXCTests.swift
//  WCS-AgenticTests
//

import SwiftData
import XCTest
@testable import WCS_Agentic

final class SwiftDataDatabaseXCTests: XCTestCase {
    @MainActor
    func testRepositoryUpsertAndFetch() throws {
        let schema = Schema([ParticipantRecord.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [configuration])
        let context = ModelContext(container)
        let repo = WorkflowRepository(modelContext: context)
        let id = UUID()
        try repo.upsertParticipant(id: id, email: "db@test.org", fullName: "DB User")
        let rows = try repo.localParticipants()
        XCTAssertEqual(rows.count, 1)
        XCTAssertEqual(rows.first?.id, id)
        XCTAssertEqual(rows.first?.email, "db@test.org")
    }
}

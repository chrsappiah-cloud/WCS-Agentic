//
//  SessionAndAccessXCTests.swift
//  WCS-AgenticTests
//

import SwiftData
import XCTest
@testable import WCS_Agentic

final class SessionAndAccessXCTests: XCTestCase {
    @MainActor
    func testUserRepositorySeedAndAdminRole() throws {
        let schema = Schema([
            ParticipantRecord.self,
            UserAccountRecord.self,
            AgentRunRecord.self,
            MonitoringEventRecord.self,
        ])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [configuration])
        let context = ModelContext(container)
        let repo = UserAccountRepository(modelContext: context)

        try repo.seedDefaultsIfEmpty()
        let admin = try repo.user(email: "admin@worldclassscholars.test")
        XCTAssertEqual(admin?.role, .admin)
        XCTAssertTrue(admin?.role.canAccessAdminPanel == true)
    }

    @MainActor
    func testSessionSignInAndAgentPermission() throws {
        let schema = Schema([
            ParticipantRecord.self,
            UserAccountRecord.self,
            AgentRunRecord.self,
            MonitoringEventRecord.self,
        ])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [configuration])
        let context = ModelContext(container)
        let session = SessionManager()
        session.attach(modelContext: context)

        session.signIn(email: "operator@worldclassscholars.test", displayName: "Op")
        XCTAssertTrue(session.isSignedIn)
        XCTAssertFalse(session.canRunAgents)

        let repo = UserAccountRepository(modelContext: context)
        if let user = session.currentUser {
            try repo.setSubscriptionTier(id: user.id, tier: .pro)
            session.refreshCurrentUser()
        }
        XCTAssertTrue(session.canRunAgents)
    }

    @MainActor
    func testDisabledAccessBlocksSignIn() throws {
        let schema = Schema([UserAccountRecord.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [configuration])
        let context = ModelContext(container)
        let repo = UserAccountRepository(modelContext: context)
        let user = try repo.upsert(email: "blocked@test.org", displayName: "Blocked")
        try repo.setAccessEnabled(id: user.id, enabled: false)

        let session = SessionManager()
        session.attach(modelContext: context)
        session.signIn(email: "blocked@test.org", displayName: "Blocked")
        XCTAssertFalse(session.isSignedIn)
        XCTAssertNotNil(session.lastError)
    }
}

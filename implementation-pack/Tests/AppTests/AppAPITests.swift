@testable import App
import Fluent
import Vapor
import XCTVapor
import XCTest

final class AppAPITests: XCTestCase {
    func testHealthReturnsOk() throws {
        let app = Application(.testing)
        defer { app.shutdown() }

        try TestingConfiguration.configure(app)
        try app.autoMigrate().wait()

        try app.test(.GET, "health", afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqual(res.body.string, "ok")
        })
    }

    func testCreateParticipantReturnsUUID() throws {
        let app = Application(.testing)
        defer { app.shutdown() }

        try TestingConfiguration.configure(app)
        try app.autoMigrate().wait()

        try app.test(
            .POST,
            "participants",
            headers: HTTPHeaders([("Content-Type", "application/json")]),
            beforeRequest: { req in
                try req.content.encode(CreateParticipant(email: "unit@test.org", fullName: "Unit Test"))
            },
            afterResponse: { res in
                XCTAssertEqual(res.status, .ok)
                let p = try res.content.decode(Participant.self)
                XCTAssertNotNil(p.id)
                XCTAssertEqual(p.email, "unit@test.org")
                XCTAssertEqual(p.fullName, "Unit Test")
            }
        )
    }

    func testApproveWorkflowRequiresExistingRun() throws {
        let app = Application(.testing)
        defer { app.shutdown() }

        try TestingConfiguration.configure(app)
        try app.autoMigrate().wait()

        let missing = ApproveRequest(workflowID: UUID(), approvedBy: "ops")
        try app.test(
            .POST,
            "workflows/approve",
            headers: HTTPHeaders([("Content-Type", "application/json")]),
            beforeRequest: { req in
                try req.content.encode(missing)
            },
            afterResponse: { res in
                XCTAssertEqual(res.status, .notFound)
            }
        )
    }
}

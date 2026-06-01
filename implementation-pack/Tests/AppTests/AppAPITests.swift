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

    func testFinanceSnapshotSeedsDatabase() throws {
        let app = Application(.testing)
        defer { app.shutdown() }

        try TestingConfiguration.configure(app)
        try app.autoMigrate().wait()

        try app.test(.GET, "finance/snapshot", afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let snapshot = try res.content.decode(FinanceWorkspaceSnapshotDTO.self)
            XCTAssertFalse(snapshot.records.isEmpty)
            XCTAssertFalse(snapshot.complianceTasks.isEmpty)
            XCTAssertFalse(snapshot.policyPacks.isEmpty)
        })
    }

    func testFinanceAccountingStatusCommandPersistsAndAudits() throws {
        let app = Application(.testing)
        defer { app.shutdown() }

        try TestingConfiguration.configure(app)
        try app.autoMigrate().wait()

        var recordID: UUID?
        try app.test(.GET, "finance/snapshot", afterResponse: { res in
            let snapshot = try res.content.decode(FinanceWorkspaceSnapshotDTO.self)
            recordID = snapshot.records.first?.id
        })

        let id = try XCTUnwrap(recordID)
        try app.test(
            .POST,
            "finance/accounting-records/\(id.uuidString)/status",
            headers: HTTPHeaders([("Content-Type", "application/json")]),
            beforeRequest: { req in
                try req.content.encode(FinanceStatusRequest(status: "approved", actor: "unit@test.wcs"))
            },
            afterResponse: { res in
                XCTAssertEqual(res.status, .ok)
                let snapshot = try res.content.decode(FinanceWorkspaceSnapshotDTO.self)
                XCTAssertEqual(snapshot.records.first { $0.id == id }?.status, "approved")
                XCTAssertEqual(snapshot.auditTrail.first?.actor, "unit@test.wcs")
            }
        )
    }

    func testFinanceReportGenerationPersistsReport() throws {
        let app = Application(.testing)
        defer { app.shutdown() }

        try TestingConfiguration.configure(app)
        try app.autoMigrate().wait()

        try app.test(
            .POST,
            "finance/reports/generate",
            headers: HTTPHeaders([("Content-Type", "application/json")]),
            beforeRequest: { req in
                try req.content.encode(GenerateFinanceReportRequest(period: "June 2026", actor: "unit@test.wcs"))
            },
            afterResponse: { res in
                XCTAssertEqual(res.status, .ok)
                let generated = try res.content.decode(GeneratedReportResponseDTO.self)
                XCTAssertEqual(generated.report.period, "June 2026")
                XCTAssertEqual(generated.auditEvent.action, "Generated report")
            }
        )
    }
}

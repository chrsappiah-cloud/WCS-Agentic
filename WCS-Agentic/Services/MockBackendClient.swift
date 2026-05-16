//
//  MockBackendClient.swift
//  WCS-Agentic
//

import Foundation

/// Deterministic backend for SwiftUI previews, UI tests, and offline demos.
struct MockBackendClient: APIServing {
    var healthBody: String = "ok"
    var nextParticipantID: UUID = UUID(uuidString: "00000000-0000-4000-8000-000000000001")!

    func health() async throws -> String {
        healthBody
    }

    func createParticipant(email: String, fullName: String) async throws -> UUID {
        _ = email
        _ = fullName
        return nextParticipantID
    }

    func uploadIdentity(participantID: UUID, documentURL: String) async throws {
        _ = participantID
        _ = documentURL
    }

    func approveWorkflow(workflowID: UUID, approvedBy: String) async throws {
        _ = workflowID
        _ = approvedBy
    }
}

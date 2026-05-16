import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.post("participants") { req async throws -> Participant in
        let input = try req.content.decode(CreateParticipant.self)
        let p = Participant(email: input.email, fullName: input.fullName)
        try await p.save(on: req.db)
        let run = WorkflowRun(
            workflowType: "onboarding",
            payload: "{\"participantID\":\"\(p.id?.uuidString ?? "")\"}",
            riskScore: 0.1
        )
        try await run.save(on: req.db)
        return p
    }

    app.post("identity", "upload") { req async throws -> HTTPStatus in
        let input = try req.content.decode(UploadIdentityRequest.self)
        guard let participant = try await Participant.find(input.participantID, on: req.db) else {
            throw Abort(.notFound)
        }
        participant.status = input.documentURL.isEmpty ? "needs_review" : "identity_submitted"
        try await participant.save(on: req.db)
        return .accepted
    }

    app.post("workflows", "approve") { req async throws -> HTTPStatus in
        let input = try req.content.decode(ApproveRequest.self)
        guard let workflow = try await WorkflowRun.find(input.workflowID, on: req.db) else {
            throw Abort(.notFound)
        }
        workflow.status = "approved"
        try await workflow.save(on: req.db)
        return .ok
    }

    app.get("health") { _ async in
        "ok"
    }
}

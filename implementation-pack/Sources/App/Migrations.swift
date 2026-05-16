import Fluent

struct CreateParticipantMigration: AsyncMigration {
    func prepare(on db: Database) async throws {
        try await db.schema(Participant.schema)
            .id()
            .field("email", .string, .required)
            .field("full_name", .string, .required)
            .field("status", .string, .required)
            .field("created_at", .datetime)
            .unique(on: "email")
            .create()
    }

    func revert(on db: Database) async throws {
        try await db.schema(Participant.schema).delete()
    }
}

struct CreateWorkflowRunMigration: AsyncMigration {
    func prepare(on db: Database) async throws {
        try await db.schema(WorkflowRun.schema)
            .id()
            .field("workflow_type", .string, .required)
            .field("status", .string, .required)
            .field("payload", .string, .required)
            .field("risk_score", .double, .required)
            .field("created_at", .datetime)
            .create()
    }

    func revert(on db: Database) async throws {
        try await db.schema(WorkflowRun.schema).delete()
    }
}

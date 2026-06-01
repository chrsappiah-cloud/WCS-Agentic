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

struct CreateFinanceSchemaMigration: AsyncMigration {
    func prepare(on db: Database) async throws {
        try await db.schema("finance_accounting_records")
            .id()
            .field("entity_id", .string, .required)
            .field("project_id", .string)
            .field("counterparty", .string, .required)
            .field("transaction_date", .datetime, .required)
            .field("posting_date", .datetime, .required)
            .field("document_type", .string, .required)
            .field("description", .string, .required)
            .field("amount", .double, .required)
            .field("currency", .string, .required)
            .field("tax_code", .string, .required)
            .field("account_code", .string, .required)
            .field("cost_center", .string)
            .field("funding_source", .string)
            .field("confidence", .double, .required)
            .field("evidence_ids", .string, .required)
            .field("status", .string, .required)
            .field("rationale", .string, .required)
            .create()

        try await db.schema("finance_compliance_tasks")
            .id()
            .field("jurisdiction", .string, .required)
            .field("regime", .string, .required)
            .field("obligation", .string, .required)
            .field("due_date", .datetime, .required)
            .field("owner", .string, .required)
            .field("severity", .string, .required)
            .field("evidence_required", .string, .required)
            .field("status", .string, .required)
            .field("recommended_action", .string, .required)
            .create()

        try await db.schema("finance_reports")
            .id()
            .field("title", .string, .required)
            .field("period", .string, .required)
            .field("sections_json", .string, .required)
            .field("decisions_json", .string, .required)
            .field("created_at", .datetime)
            .create()

        try await db.schema("finance_audit_events")
            .id()
            .field("timestamp", .datetime, .required)
            .field("actor", .string, .required)
            .field("action", .string, .required)
            .field("object", .string, .required)
            .field("rationale", .string, .required)
            .create()
    }

    func revert(on db: Database) async throws {
        try await db.schema("finance_audit_events").delete()
        try await db.schema("finance_reports").delete()
        try await db.schema("finance_compliance_tasks").delete()
        try await db.schema("finance_accounting_records").delete()
    }
}

import Fluent
import Vapor

struct CreateParticipant: Content {
    let email: String
    let fullName: String
}

struct UploadIdentityRequest: Content {
    let participantID: UUID
    let documentURL: String
}

struct ApproveRequest: Content {
    let workflowID: UUID
    let approvedBy: String
}

final class Participant: Model, Content, @unchecked Sendable {
    static let schema = "participants"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "email")
    var email: String

    @Field(key: "full_name")
    var fullName: String

    @Field(key: "status")
    var status: String

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    init() {}

    init(id: UUID? = nil, email: String, fullName: String, status: String = "pending") {
        self.id = id
        self.email = email
        self.fullName = fullName
        self.status = status
    }
}

final class WorkflowRun: Model, Content, @unchecked Sendable {
    static let schema = "workflow_runs"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "workflow_type")
    var workflowType: String

    @Field(key: "status")
    var status: String

    @Field(key: "payload")
    var payload: String

    @Field(key: "risk_score")
    var riskScore: Double

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    init() {}

    init(workflowType: String, status: String = "queued", payload: String = "{}", riskScore: Double = 0) {
        self.workflowType = workflowType
        self.status = status
        self.payload = payload
        self.riskScore = riskScore
    }
}

struct MoneyDTO: Content, Equatable {
    let amount: Double
    let currency: String
}

struct SourceEvidenceDTO: Content, Equatable {
    let id: UUID
    let fileName: String
    let sourceType: String
    let extractedText: String
    let checksum: String
    let capturedAt: Date
}

struct AccountingRecordDTO: Content, Equatable {
    let id: UUID
    let entityId: String
    let projectId: String?
    let counterparty: String
    let transactionDate: Date
    let postingDate: Date
    let documentType: String
    let description: String
    let amount: MoneyDTO
    let taxCode: String
    let accountCode: String
    let costCenter: String?
    let fundingSource: String?
    let confidence: Double
    let evidenceIds: [UUID]
    let status: String
    let rationale: String
}

struct ComplianceTaskDTO: Content, Equatable {
    let id: UUID
    let jurisdiction: String
    let regime: String
    let obligation: String
    let dueDate: Date
    let owner: String
    let severity: String
    let evidenceRequired: [String]
    let status: String
    let recommendedAction: String
}

struct GovernanceEventDTO: Content, Equatable {
    let id: UUID
    let eventType: String
    let meetingDate: Date?
    let resolutionText: String
    let approvers: [String]
    let relatedRecords: [UUID]
    let followUpTasks: [UUID]
    let explainabilityNote: String
}

struct GrantMilestoneDTO: Content, Equatable {
    let id: UUID
    let title: String
    let dueDate: Date
    let requiredEvidence: [String]
    let trancheAmount: MoneyDTO?
}

struct GrantAgreementDTO: Content, Equatable {
    let id: UUID
    let grantName: String
    let fundingBody: String
    let startDate: Date
    let endDate: Date
    let eligibleCostRules: [String]
    let milestones: [GrantMilestoneDTO]
    let reportingDeadlines: [Date]
}

struct ReportSectionDTO: Content, Equatable {
    let id: UUID
    let heading: String
    let body: String
    let evidenceRefs: [String]
}

struct FinanceReportDTO: Content, Equatable {
    let id: UUID
    let title: String
    let period: String
    let sections: [ReportSectionDTO]
    let decisionsRequired: [String]
}

struct AuditEventDTO: Content, Equatable {
    let id: UUID
    let timestamp: Date
    let actor: String
    let action: String
    let object: String
    let rationale: String
}

struct PolicyPackDTO: Content, Equatable {
    let id: UUID
    let title: String
    let controls: [String]
    let reviewer: String
    let status: String
}

struct FinanceWorkspaceSnapshotDTO: Content, Equatable {
    let evidence: [SourceEvidenceDTO]
    let records: [AccountingRecordDTO]
    let complianceTasks: [ComplianceTaskDTO]
    let governanceEvents: [GovernanceEventDTO]
    let grants: [GrantAgreementDTO]
    let auditTrail: [AuditEventDTO]
    let policyPacks: [PolicyPackDTO]
    let reports: [FinanceReportDTO]
}

struct FinanceStatusRequest: Content {
    let status: String
    let actor: String?
}

struct FinanceActorRequest: Content {
    let actor: String?
}

struct GenerateFinanceReportRequest: Content {
    let period: String
    let actor: String?
}

struct GeneratedReportResponseDTO: Content, Equatable {
    let report: FinanceReportDTO
    let auditEvent: AuditEventDTO
}

final class FinanceAccountingRecord: Model, @unchecked Sendable {
    static let schema = "finance_accounting_records"

    @ID(key: .id) var id: UUID?
    @Field(key: "entity_id") var entityId: String
    @OptionalField(key: "project_id") var projectId: String?
    @Field(key: "counterparty") var counterparty: String
    @Field(key: "transaction_date") var transactionDate: Date
    @Field(key: "posting_date") var postingDate: Date
    @Field(key: "document_type") var documentType: String
    @Field(key: "description") var recordDescription: String
    @Field(key: "amount") var amount: Double
    @Field(key: "currency") var currency: String
    @Field(key: "tax_code") var taxCode: String
    @Field(key: "account_code") var accountCode: String
    @OptionalField(key: "cost_center") var costCenter: String?
    @OptionalField(key: "funding_source") var fundingSource: String?
    @Field(key: "confidence") var confidence: Double
    @Field(key: "evidence_ids") var evidenceIdsJSON: String
    @Field(key: "status") var status: String
    @Field(key: "rationale") var rationale: String

    init() {}
}

final class FinanceComplianceTask: Model, @unchecked Sendable {
    static let schema = "finance_compliance_tasks"

    @ID(key: .id) var id: UUID?
    @Field(key: "jurisdiction") var jurisdiction: String
    @Field(key: "regime") var regime: String
    @Field(key: "obligation") var obligation: String
    @Field(key: "due_date") var dueDate: Date
    @Field(key: "owner") var owner: String
    @Field(key: "severity") var severity: String
    @Field(key: "evidence_required") var evidenceRequiredJSON: String
    @Field(key: "status") var status: String
    @Field(key: "recommended_action") var recommendedAction: String

    init() {}
}

final class FinanceReportRecord: Model, @unchecked Sendable {
    static let schema = "finance_reports"

    @ID(key: .id) var id: UUID?
    @Field(key: "title") var title: String
    @Field(key: "period") var period: String
    @Field(key: "sections_json") var sectionsJSON: String
    @Field(key: "decisions_json") var decisionsJSON: String
    @Timestamp(key: "created_at", on: .create) var createdAt: Date?

    init() {}
}

final class FinanceAuditEventRecord: Model, @unchecked Sendable {
    static let schema = "finance_audit_events"

    @ID(key: .id) var id: UUID?
    @Field(key: "timestamp") var timestamp: Date
    @Field(key: "actor") var actor: String
    @Field(key: "action") var action: String
    @Field(key: "object") var object: String
    @Field(key: "rationale") var rationale: String

    init() {}
}

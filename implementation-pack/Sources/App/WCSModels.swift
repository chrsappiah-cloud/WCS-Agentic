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

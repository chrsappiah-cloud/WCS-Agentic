//
//  FinanceAgentModels.swift
//  WCS-Agentic
//

import Foundation

struct Money: Codable, Hashable {
    let amount: Decimal
    let currency: String

    var display: String {
        let number = NSDecimalNumber(decimal: amount)
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        formatter.maximumFractionDigits = 2
        return formatter.string(from: number) ?? "\(currency) \(number)"
    }
}

struct SourceEvidence: Codable, Identifiable, Hashable {
    let id: UUID
    let fileName: String
    let sourceType: String
    let extractedText: String
    let checksum: String
    let capturedAt: Date
}

struct AccountingRecord: Codable, Identifiable, Hashable {
    let id: UUID
    let entityId: String
    let projectId: String?
    let counterparty: String
    let transactionDate: Date
    let postingDate: Date
    let documentType: String
    let description: String
    let amount: Money
    let taxCode: String
    let accountCode: String
    let costCenter: String?
    let fundingSource: String?
    let confidence: Double
    let evidenceIds: [UUID]
    var status: RecordStatus
    var rationale: String

    var requiresHumanApproval: Bool {
        confidence < 0.86 || status == .escalated || documentType.localizedCaseInsensitiveContains("grant")
    }
}

enum RecordStatus: String, Codable, CaseIterable {
    case draft, suggested, approved, posted, escalated, rejected
}

struct ComplianceTask: Codable, Identifiable, Hashable {
    let id: UUID
    let jurisdiction: String
    let regime: String
    let obligation: String
    let dueDate: Date
    let owner: String
    let severity: Severity
    let evidenceRequired: [String]
    var status: TaskStatus
    let recommendedAction: String
}

enum Severity: String, Codable, CaseIterable {
    case low, medium, high, critical
}

enum TaskStatus: String, Codable, CaseIterable {
    case open, inProgress, blocked, completed, overdue
}

struct GovernanceEvent: Codable, Identifiable, Hashable {
    let id: UUID
    let eventType: String
    let meetingDate: Date?
    let resolutionText: String
    let approvers: [String]
    let relatedRecords: [UUID]
    let followUpTasks: [UUID]
    let explainabilityNote: String
}

struct GrantAgreement: Codable, Identifiable, Hashable {
    let id: UUID
    let grantName: String
    let fundingBody: String
    let startDate: Date
    let endDate: Date
    let eligibleCostRules: [String]
    let milestones: [GrantMilestone]
    let reportingDeadlines: [Date]
}

struct GrantMilestone: Codable, Identifiable, Hashable {
    let id: UUID
    let title: String
    let dueDate: Date
    let requiredEvidence: [String]
    let trancheAmount: Money?
}

struct FinanceReport: Codable, Identifiable, Hashable {
    let id: UUID
    let title: String
    let period: String
    let sections: [ReportSection]
    let decisionsRequired: [String]
}

struct ReportSection: Codable, Identifiable, Hashable {
    let id: UUID
    let heading: String
    let body: String
    let evidenceRefs: [String]
}

struct AuditEvent: Codable, Identifiable, Hashable {
    let id: UUID
    let timestamp: Date
    let actor: String
    let action: String
    let object: String
    let rationale: String
}

struct PolicyPack: Codable, Identifiable, Hashable {
    let id: UUID
    let title: String
    let controls: [String]
    let reviewer: String
    let status: String
}

struct FinanceWorkspaceSnapshot: Codable, Hashable {
    let evidence: [SourceEvidence]
    let records: [AccountingRecord]
    let complianceTasks: [ComplianceTask]
    let governanceEvents: [GovernanceEvent]
    let grants: [GrantAgreement]
    let auditTrail: [AuditEvent]
    let policyPacks: [PolicyPack]
    let reports: [FinanceReport]
}

struct GeneratedReportResponse: Codable, Hashable {
    let report: FinanceReport
    let auditEvent: AuditEvent
}

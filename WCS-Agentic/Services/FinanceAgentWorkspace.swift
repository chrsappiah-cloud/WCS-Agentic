//
//  FinanceAgentWorkspace.swift
//  WCS-Agentic
//

import Combine
import Foundation

@MainActor
final class FinanceAgentWorkspace: ObservableObject {
    @Published private(set) var records: [AccountingRecord]
    @Published private(set) var complianceTasks: [ComplianceTask]
    @Published private(set) var governanceEvents: [GovernanceEvent]
    @Published private(set) var grants: [GrantAgreement]
    @Published private(set) var evidence: [SourceEvidence]
    @Published private(set) var auditTrail: [AuditEvent]
    @Published private(set) var policyPacks: [PolicyPack]
    @Published private(set) var reports: [FinanceReport]
    @Published private(set) var isSyncing = false
    @Published private(set) var lastBackendMessage: String?

    init(seed: FinanceAgentSeed = .demo) {
        evidence = seed.evidence
        records = seed.records
        complianceTasks = seed.complianceTasks
        governanceEvents = seed.governanceEvents
        grants = seed.grants
        auditTrail = seed.auditTrail
        policyPacks = seed.policyPacks
        reports = seed.reports
    }

    func apply(snapshot: FinanceWorkspaceSnapshot, message: String? = nil) {
        evidence = snapshot.evidence
        records = snapshot.records
        complianceTasks = snapshot.complianceTasks
        governanceEvents = snapshot.governanceEvents
        grants = snapshot.grants
        auditTrail = snapshot.auditTrail
        policyPacks = snapshot.policyPacks
        reports = snapshot.reports
        lastBackendMessage = message
    }

    func sync(api: APIServing) async {
        await runBackendCommand("Synced finance workspace") {
            apply(snapshot: try await api.fetchFinanceSnapshot(), message: "Finance workspace synced from backend.")
        }
    }

    var inboxRecords: [AccountingRecord] {
        records.filter { $0.status == .suggested || $0.status == .escalated || $0.status == .draft }
    }

    var approvalRequiredCount: Int {
        records.filter(\.requiresHumanApproval).count + complianceTasks.filter { $0.severity == .high || $0.severity == .critical }.count
    }

    var postedTotal: Decimal {
        records.filter { $0.status == .posted || $0.status == .approved }.reduce(Decimal(0)) { $0 + $1.amount.amount }
    }

    var complianceRisk: String {
        if complianceTasks.contains(where: { $0.severity == .critical && $0.status != .completed }) {
            return "Breach risk"
        }
        if complianceTasks.contains(where: { ($0.severity == .high || $0.status == .overdue) && $0.status != .completed }) {
            return "At risk"
        }
        return "On track"
    }

    func approve(_ record: AccountingRecord, actor: String = "finance.operator@worldclassscholars.test") {
        updateRecord(record, status: .approved, actor: actor, action: "Approved ledger suggestion")
    }

    func approve(_ record: AccountingRecord, api: APIServing, actor: String = "finance.operator@worldclassscholars.test") async {
        await setStatus(record, status: .approved, api: api, actor: actor)
    }

    func post(_ record: AccountingRecord, actor: String = "finance.manager@worldclassscholars.test") {
        updateRecord(record, status: .posted, actor: actor, action: "Posted approved accounting record")
    }

    func post(_ record: AccountingRecord, api: APIServing, actor: String = "finance.manager@worldclassscholars.test") async {
        await setStatus(record, status: .posted, api: api, actor: actor)
    }

    func escalate(_ record: AccountingRecord, actor: String = "finance.operator@worldclassscholars.test") {
        updateRecord(record, status: .escalated, actor: actor, action: "Escalated for human review")
    }

    func escalate(_ record: AccountingRecord, api: APIServing, actor: String = "finance.operator@worldclassscholars.test") async {
        await setStatus(record, status: .escalated, api: api, actor: actor)
    }

    func complete(_ task: ComplianceTask, actor: String = "governance.lead@worldclassscholars.test") {
        guard let index = complianceTasks.firstIndex(where: { $0.id == task.id }) else { return }
        complianceTasks[index].status = .completed
        log(actor: actor, action: "Completed compliance task", object: task.obligation, rationale: task.recommendedAction)
    }

    func complete(_ task: ComplianceTask, api: APIServing, actor: String = "governance.lead@worldclassscholars.test") async {
        await runBackendCommand("Completed compliance task") {
            apply(
                snapshot: try await api.completeComplianceTask(id: task.id, actor: actor),
                message: "Compliance task completed in backend."
            )
        }
    }

    func addBoardApprovalNote(for event: GovernanceEvent, actor: String = "board.secretary@worldclassscholars.test") {
        log(actor: actor, action: "Captured governance approval note", object: event.eventType, rationale: event.explainabilityNote)
    }

    func addBoardApprovalNote(for event: GovernanceEvent, api: APIServing, actor: String = "board.secretary@worldclassscholars.test") async {
        await runBackendCommand("Captured governance approval note") {
            apply(
                snapshot: try await api.captureGovernanceApprovalNote(id: event.id, actor: actor),
                message: "Governance approval note captured in backend."
            )
        }
    }

    func generateReport(api: APIServing, period: String = "Current period", actor: String = "finance.manager@worldclassscholars.test") async {
        await runBackendCommand("Generated finance report") {
            let response = try await api.generateFinanceReport(period: period, actor: actor)
            reports.insert(response.report, at: 0)
            auditTrail.insert(response.auditEvent, at: 0)
            lastBackendMessage = "Generated \(response.report.title)."
        }
    }

    private func setStatus(_ record: AccountingRecord, status: RecordStatus, api: APIServing, actor: String) async {
        await runBackendCommand("Updated accounting record") {
            apply(
                snapshot: try await api.updateAccountingRecordStatus(id: record.id, status: status, actor: actor),
                message: "Accounting record marked \(status.rawValue)."
            )
        }
    }

    private func runBackendCommand(_ fallbackAction: String, operation: () async throws -> Void) async {
        isSyncing = true
        defer { isSyncing = false }
        do {
            try await operation()
        } catch {
            lastBackendMessage = "\(fallbackAction) locally; backend unavailable: \(error.localizedDescription)"
        }
    }

    private func updateRecord(_ record: AccountingRecord, status: RecordStatus, actor: String, action: String) {
        guard let index = records.firstIndex(where: { $0.id == record.id }) else { return }
        records[index].status = status
        log(actor: actor, action: action, object: record.description, rationale: record.rationale)
    }

    private func log(actor: String, action: String, object: String, rationale: String) {
        auditTrail.insert(
            AuditEvent(
                id: UUID(),
                timestamp: Date(),
                actor: actor,
                action: action,
                object: object,
                rationale: rationale
            ),
            at: 0
        )
    }
}

struct FinanceAgentSeed {
    let evidence: [SourceEvidence]
    let records: [AccountingRecord]
    let complianceTasks: [ComplianceTask]
    let governanceEvents: [GovernanceEvent]
    let grants: [GrantAgreement]
    let auditTrail: [AuditEvent]
    let policyPacks: [PolicyPack]
    let reports: [FinanceReport]

    nonisolated static var demo: FinanceAgentSeed {
        let now = Date()
        let calendar = Calendar(identifier: .gregorian)
        let invoiceEvidence = SourceEvidence(
            id: UUID(),
            fileName: "Atlassian-May-2026.pdf",
            sourceType: "Supplier invoice",
            extractedText: "Atlassian cloud subscription, May 2026, GST included.",
            checksum: "sha256:7f4d-demo-atlassian",
            capturedAt: now
        )
        let grantEvidence = SourceEvidence(
            id: UUID(),
            fileName: "Innovation-Grant-Agreement.pdf",
            sourceType: "Grant contract",
            extractedText: "Milestone 2 requires eligible expenditure report, payroll evidence, and board sign-off.",
            checksum: "sha256:91aa-demo-grant",
            capturedAt: now
        )
        let bankEvidence = SourceEvidence(
            id: UUID(),
            fileName: "BankFeed-2026-05.csv",
            sourceType: "Bank feed",
            extractedText: "Stripe payout and payroll clearing transactions for May 2026.",
            checksum: "sha256:aa03-demo-bankfeed",
            capturedAt: now
        )
        let atoEvidence = SourceEvidence(
            id: UUID(),
            fileName: "ATO-BAS-Q4-Reminder.eml",
            sourceType: "ATO correspondence",
            extractedText: "Business activity statement preparation reminder for June quarter.",
            checksum: "sha256:cc18-demo-ato",
            capturedAt: now
        )

        let records = [
            AccountingRecord(
                id: UUID(),
                entityId: "WCS-AU",
                projectId: "OPS",
                counterparty: "Atlassian Pty Ltd",
                transactionDate: now,
                postingDate: now,
                documentType: "Supplier invoice",
                description: "Cloud collaboration tools for program delivery",
                amount: Money(amount: Decimal(429.00), currency: "AUD"),
                taxCode: "GST",
                accountCode: "6200 Software subscriptions",
                costCenter: "Operations",
                fundingSource: nil,
                confidence: 0.94,
                evidenceIds: [invoiceEvidence.id],
                status: .suggested,
                rationale: "Supplier, invoice wording, and GST treatment match the software subscription policy."
            ),
            AccountingRecord(
                id: UUID(),
                entityId: "WCS-AU",
                projectId: "GRANT-INNOVATION",
                counterparty: "World Class Scholars Payroll",
                transactionDate: calendar.date(byAdding: .day, value: -5, to: now) ?? now,
                postingDate: now,
                documentType: "Grant payroll allocation",
                description: "Grant-funded engineering payroll allocation",
                amount: Money(amount: Decimal(8400.00), currency: "AUD"),
                taxCode: "N-T",
                accountCode: "5100 Salaries and wages",
                costCenter: "Product",
                fundingSource: "Innovation Grant",
                confidence: 0.78,
                evidenceIds: [grantEvidence.id, bankEvidence.id],
                status: .escalated,
                rationale: "Eligible-cost rule requires payroll support and grant manager approval before posting."
            ),
            AccountingRecord(
                id: UUID(),
                entityId: "WCS-AU",
                projectId: "REVENUE",
                counterparty: "Stripe",
                transactionDate: calendar.date(byAdding: .day, value: -2, to: now) ?? now,
                postingDate: now,
                documentType: "Bank feed",
                description: "Scholar subscription payout net of fees",
                amount: Money(amount: Decimal(12650.45), currency: "AUD"),
                taxCode: "GST",
                accountCode: "4100 Program revenue",
                costCenter: "Programs",
                fundingSource: nil,
                confidence: 0.88,
                evidenceIds: [bankEvidence.id],
                status: .suggested,
                rationale: "Bank feed description and recurring Stripe counterparty match program revenue rules."
            )
        ]

        let tasks = [
            ComplianceTask(
                id: UUID(),
                jurisdiction: "Australia",
                regime: "Tax",
                obligation: "Prepare June quarter BAS workpaper",
                dueDate: calendar.date(byAdding: .day, value: 28, to: now) ?? now,
                owner: "Finance Manager",
                severity: .high,
                evidenceRequired: ["GST detail report", "Bank reconciliation", "Approved ledger exceptions"],
                status: .inProgress,
                recommendedAction: "Resolve escalated GST and payroll records before adviser review."
            ),
            ComplianceTask(
                id: UUID(),
                jurisdiction: "Australia",
                regime: "Company administration",
                obligation: "Refresh conflicts and related-party register",
                dueDate: calendar.date(byAdding: .day, value: 14, to: now) ?? now,
                owner: "Company Secretary",
                severity: .medium,
                evidenceRequired: ["Director attestations", "Board minutes"],
                status: .open,
                recommendedAction: "Collect director confirmations ahead of the next board pack."
            ),
            ComplianceTask(
                id: UUID(),
                jurisdiction: "Australia",
                regime: "Privacy",
                obligation: "Review document capture retention settings",
                dueDate: calendar.date(byAdding: .day, value: 7, to: now) ?? now,
                owner: "Operations Lead",
                severity: .medium,
                evidenceRequired: ["Retention schedule", "Consent log", "Deletion exception report"],
                status: .open,
                recommendedAction: "Confirm evidence retention aligns with policy pack before production rollout."
            )
        ]

        let milestone = GrantMilestone(
            id: UUID(),
            title: "Milestone 2 acquittal pack",
            dueDate: calendar.date(byAdding: .day, value: 42, to: now) ?? now,
            requiredEvidence: ["Payroll allocation report", "Eligible cost schedule", "Board sign-off"],
            trancheAmount: Money(amount: Decimal(25000), currency: "AUD")
        )
        let grant = GrantAgreement(
            id: UUID(),
            grantName: "Innovation Grant",
            fundingBody: "State innovation program",
            startDate: calendar.date(byAdding: .month, value: -3, to: now) ?? now,
            endDate: calendar.date(byAdding: .month, value: 9, to: now) ?? now,
            eligibleCostRules: ["Payroll must map to approved project staff.", "Software costs require invoice evidence.", "Acquittals require reviewer sign-off."],
            milestones: [milestone],
            reportingDeadlines: [milestone.dueDate]
        )

        let governance = [
            GovernanceEvent(
                id: UUID(),
                eventType: "Board resolution",
                meetingDate: calendar.date(byAdding: .day, value: -10, to: now),
                resolutionText: "Approve supervised finance-agent pilot with mandatory human approval for filings, tax, grants, cap table, and board reports.",
                approvers: ["Chair", "Founder", "Finance Director"],
                relatedRecords: records.map(\.id),
                followUpTasks: tasks.map(\.id),
                explainabilityNote: "The control model preserves accountability by separating preparer, reviewer, and approver actions."
            )
        ]

        let reports = [
            FinanceReport(
                id: UUID(),
                title: "Monthly finance and governance brief",
                period: "May 2026",
                sections: [
                    ReportSection(
                        id: UUID(),
                        heading: "Executive overview",
                        body: "Program revenue and grant spending are ready for management review, with one grant payroll allocation held for evidence confirmation.",
                        evidenceRefs: [bankEvidence.fileName, grantEvidence.fileName]
                    ),
                    ReportSection(
                        id: UUID(),
                        heading: "Cash and runway",
                        body: "Cash movement is driven by Stripe receipts and controlled operating subscriptions; forecast release needs posted ledger confirmation.",
                        evidenceRefs: [bankEvidence.fileName, invoiceEvidence.fileName]
                    ),
                    ReportSection(
                        id: UUID(),
                        heading: "Compliance exceptions",
                        body: "BAS workpaper preparation is at risk until escalated records are reviewed and evidence links are complete.",
                        evidenceRefs: [atoEvidence.fileName]
                    )
                ],
                decisionsRequired: [
                    "Approve or reject grant payroll allocation.",
                    "Confirm BAS reviewer and evidence pack owner.",
                    "Approve board-pack release after exception list is cleared."
                ]
            )
        ]

        let policies = [
            PolicyPack(
                id: UUID(),
                title: "Founder governance pack",
                controls: ["Company constitution", "Founder IP assignment", "Board charter", "SaaS terms", "Privacy and security policies"],
                reviewer: "Board of Directors",
                status: "Generated from WCS-GOV-FOUNDER-PACK"
            ),
            PolicyPack(
                id: UUID(),
                title: "Australian tax pack",
                controls: ["GST/BAS workflow", "PAYG withholding checklist", "Superannuation scheduling", "Record retention"],
                reviewer: "External accountant",
                status: "Draft for adviser validation"
            ),
            PolicyPack(
                id: UUID(),
                title: "Grant pack",
                controls: ["Eligible expenditure rules", "Milestone evidence", "Co-contribution tracking", "Acquittal schedule"],
                reviewer: "Grant manager",
                status: "Active pilot"
            ),
            PolicyPack(
                id: UUID(),
                title: "Governance pack",
                controls: ["Delegations", "Conflicts register", "Related-party flags", "Board approval gates"],
                reviewer: "Company secretary",
                status: "Active pilot"
            )
        ]

        let audit = [
            AuditEvent(
                id: UUID(),
                timestamp: now,
                actor: "system",
                action: "Loaded supervised finance workspace",
                object: "World Class Scholars AU pilot",
                rationale: "Seed data demonstrates governed ingestion, reporting, compliance, grants, and approval workflows."
            )
        ]

        return FinanceAgentSeed(
            evidence: [invoiceEvidence, grantEvidence, bankEvidence, atoEvidence],
            records: records,
            complianceTasks: tasks,
            governanceEvents: governance,
            grants: [grant],
            auditTrail: audit,
            policyPacks: policies,
            reports: reports
        )
    }
}

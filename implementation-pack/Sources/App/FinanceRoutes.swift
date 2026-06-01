import Fluent
import Vapor

func financeRoutes(_ app: Application) throws {
    app.group("finance") { finance in
        finance.get("snapshot") { req async throws -> FinanceWorkspaceSnapshotDTO in
            try await ensureFinanceSeed(on: req.db)
            return try await financeSnapshot(on: req.db)
        }

        finance.post("accounting-records", ":id", "status") { req async throws -> FinanceWorkspaceSnapshotDTO in
            try await ensureFinanceSeed(on: req.db)
            let input = try req.content.decode(FinanceStatusRequest.self)
            guard let id = req.parameters.get("id", as: UUID.self),
                  let record = try await FinanceAccountingRecord.find(id, on: req.db)
            else {
                throw Abort(.notFound)
            }
            guard ["draft", "suggested", "approved", "posted", "escalated", "rejected"].contains(input.status) else {
                throw Abort(.badRequest, reason: "Unsupported accounting status.")
            }
            record.status = input.status
            try await record.save(on: req.db)
            _ = try await appendFinanceAudit(
                actor: input.actor ?? "finance.operator@worldclassscholars.test",
                action: "Updated accounting record status",
                object: record.recordDescription,
                rationale: "UI command set status to \(input.status).",
                on: req.db
            )
            return try await financeSnapshot(on: req.db)
        }

        finance.post("compliance-tasks", ":id", "complete") { req async throws -> FinanceWorkspaceSnapshotDTO in
            try await ensureFinanceSeed(on: req.db)
            let input = try req.content.decode(FinanceActorRequest.self)
            guard let id = req.parameters.get("id", as: UUID.self),
                  let task = try await FinanceComplianceTask.find(id, on: req.db)
            else {
                throw Abort(.notFound)
            }
            task.status = "completed"
            try await task.save(on: req.db)
            _ = try await appendFinanceAudit(
                actor: input.actor ?? "governance.lead@worldclassscholars.test",
                action: "Completed compliance task",
                object: task.obligation,
                rationale: task.recommendedAction,
                on: req.db
            )
            return try await financeSnapshot(on: req.db)
        }

        finance.post("governance-events", ":id", "approval-note") { req async throws -> FinanceWorkspaceSnapshotDTO in
            try await ensureFinanceSeed(on: req.db)
            let input = try req.content.decode(FinanceActorRequest.self)
            let event = staticGovernanceEvents().first { $0.id.uuidString == req.parameters.get("id") }
            guard let event else { throw Abort(.notFound) }
            _ = try await appendFinanceAudit(
                actor: input.actor ?? "board.secretary@worldclassscholars.test",
                action: "Captured governance approval note",
                object: event.eventType,
                rationale: event.explainabilityNote,
                on: req.db
            )
            return try await financeSnapshot(on: req.db)
        }

        finance.post("reports", "generate") { req async throws -> GeneratedReportResponseDTO in
            try await ensureFinanceSeed(on: req.db)
            let input = try req.content.decode(GenerateFinanceReportRequest.self)
            let actor = input.actor ?? "finance.manager@worldclassscholars.test"
            let snapshot = try await financeSnapshot(on: req.db)
            let report = try await generateReportWithOpenAI(input: input, snapshot: snapshot, req: req)
            let row = FinanceReportRecord()
            row.id = report.id
            row.title = report.title
            row.period = report.period
            row.sectionsJSON = try jsonString(report.sections)
            row.decisionsJSON = try jsonString(report.decisionsRequired)
            try await row.save(on: req.db)
            let audit = try await appendFinanceAudit(
                actor: actor,
                action: "Generated report",
                object: report.title,
                rationale: "Report engine generated a structured board-ready finance report.",
                on: req.db
            )
            return GeneratedReportResponseDTO(report: report, auditEvent: audit)
        }
    }
}

private func ensureFinanceSeed(on db: Database) async throws {
    let count = try await FinanceAccountingRecord.query(on: db).count()
    guard count == 0 else { return }
    let seed = staticFinanceSeed()

    for dto in seed.records {
        let row = FinanceAccountingRecord()
        row.id = dto.id
        row.entityId = dto.entityId
        row.projectId = dto.projectId
        row.counterparty = dto.counterparty
        row.transactionDate = dto.transactionDate
        row.postingDate = dto.postingDate
        row.documentType = dto.documentType
        row.recordDescription = dto.description
        row.amount = dto.amount.amount
        row.currency = dto.amount.currency
        row.taxCode = dto.taxCode
        row.accountCode = dto.accountCode
        row.costCenter = dto.costCenter
        row.fundingSource = dto.fundingSource
        row.confidence = dto.confidence
        row.evidenceIdsJSON = try jsonString(dto.evidenceIds)
        row.status = dto.status
        row.rationale = dto.rationale
        try await row.save(on: db)
    }

    for dto in seed.complianceTasks {
        let row = FinanceComplianceTask()
        row.id = dto.id
        row.jurisdiction = dto.jurisdiction
        row.regime = dto.regime
        row.obligation = dto.obligation
        row.dueDate = dto.dueDate
        row.owner = dto.owner
        row.severity = dto.severity
        row.evidenceRequiredJSON = try jsonString(dto.evidenceRequired)
        row.status = dto.status
        row.recommendedAction = dto.recommendedAction
        try await row.save(on: db)
    }

    for report in seed.reports {
        let row = FinanceReportRecord()
        row.id = report.id
        row.title = report.title
        row.period = report.period
        row.sectionsJSON = try jsonString(report.sections)
        row.decisionsJSON = try jsonString(report.decisionsRequired)
        try await row.save(on: db)
    }

    for audit in seed.auditTrail {
        _ = try await appendFinanceAudit(
            actor: audit.actor,
            action: audit.action,
            object: audit.object,
            rationale: audit.rationale,
            id: audit.id,
            timestamp: audit.timestamp,
            on: db
        )
    }
}

private func financeSnapshot(on db: Database) async throws -> FinanceWorkspaceSnapshotDTO {
    let seed = staticFinanceSeed()
    let records = try await FinanceAccountingRecord.query(on: db).all().map { row in
        AccountingRecordDTO(
            id: row.id!,
            entityId: row.entityId,
            projectId: row.projectId,
            counterparty: row.counterparty,
            transactionDate: row.transactionDate,
            postingDate: row.postingDate,
            documentType: row.documentType,
            description: row.recordDescription,
            amount: MoneyDTO(amount: row.amount, currency: row.currency),
            taxCode: row.taxCode,
            accountCode: row.accountCode,
            costCenter: row.costCenter,
            fundingSource: row.fundingSource,
            confidence: row.confidence,
            evidenceIds: try jsonDecode([UUID].self, from: row.evidenceIdsJSON),
            status: row.status,
            rationale: row.rationale
        )
    }
    let tasks = try await FinanceComplianceTask.query(on: db).all().map { row in
        ComplianceTaskDTO(
            id: row.id!,
            jurisdiction: row.jurisdiction,
            regime: row.regime,
            obligation: row.obligation,
            dueDate: row.dueDate,
            owner: row.owner,
            severity: row.severity,
            evidenceRequired: try jsonDecode([String].self, from: row.evidenceRequiredJSON),
            status: row.status,
            recommendedAction: row.recommendedAction
        )
    }
    let reports = try await FinanceReportRecord.query(on: db).sort(\.$createdAt, .descending).all().map { row in
        FinanceReportDTO(
            id: row.id!,
            title: row.title,
            period: row.period,
            sections: try jsonDecode([ReportSectionDTO].self, from: row.sectionsJSON),
            decisionsRequired: try jsonDecode([String].self, from: row.decisionsJSON)
        )
    }
    let audit = try await FinanceAuditEventRecord.query(on: db).sort(\.$timestamp, .descending).all().map { row in
        AuditEventDTO(
            id: row.id!,
            timestamp: row.timestamp,
            actor: row.actor,
            action: row.action,
            object: row.object,
            rationale: row.rationale
        )
    }
    return FinanceWorkspaceSnapshotDTO(
        evidence: seed.evidence,
        records: records,
        complianceTasks: tasks,
        governanceEvents: seed.governanceEvents,
        grants: seed.grants,
        auditTrail: audit,
        policyPacks: seed.policyPacks,
        reports: reports
    )
}

private func generateReportWithOpenAI(
    input: GenerateFinanceReportRequest,
    snapshot: FinanceWorkspaceSnapshotDTO,
    req: Request
) async throws -> FinanceReportDTO {
    guard let apiKey = Environment.get("OPENAI_API_KEY"), !apiKey.isEmpty else {
        return deterministicFinanceReport(period: input.period, snapshot: snapshot)
    }

    let prompt = """
    Generate a concise finance and governance report for World Class Scholars Australia.
    Return JSON only with title, period, sections, and decisionsRequired.
    Period: \(input.period)
    Records: \(snapshot.records.map { "\($0.description): \($0.status) \($0.amount.amount) \($0.amount.currency)" }.joined(separator: "; "))
    Compliance: \(snapshot.complianceTasks.map { "\($0.obligation): \($0.status) \($0.severity)" }.joined(separator: "; "))
    Evidence: \(snapshot.evidence.map(\.fileName).joined(separator: ", "))
    """

    do {
        let body: [String: Any] = [
            "model": Environment.get("OPENAI_REPORT_MODEL") ?? "gpt-4.1-mini",
            "input": prompt,
            "text": [
                "format": [
                    "type": "json_schema",
                    "name": "finance_report",
                    "strict": true,
                    "schema": [
                        "type": "object",
                        "additionalProperties": false,
                        "properties": [
                            "title": ["type": "string"],
                            "period": ["type": "string"],
                            "sections": [
                                "type": "array",
                                "items": [
                                    "type": "object",
                                    "additionalProperties": false,
                                    "properties": [
                                        "heading": ["type": "string"],
                                        "body": ["type": "string"],
                                        "evidenceRefs": ["type": "array", "items": ["type": "string"]]
                                    ],
                                    "required": ["heading", "body", "evidenceRefs"]
                                ]
                            ],
                            "decisionsRequired": ["type": "array", "items": ["type": "string"]]
                        ],
                        "required": ["title", "period", "sections", "decisionsRequired"]
                    ]
                ]
            ]
        ]
        let json = try JSONSerialization.data(withJSONObject: body)
        let response = try await req.client.post("https://api.openai.com/v1/responses") { openAIReq in
            openAIReq.headers.bearerAuthorization = BearerAuthorization(token: apiKey)
            openAIReq.headers.contentType = .json
            openAIReq.body = .init(data: json)
        }
        guard response.status == .ok else {
            return deterministicFinanceReport(period: input.period, snapshot: snapshot)
        }
        if let data = response.body.map({ Data(buffer: $0) }),
           let generated = try parseOpenAIReport(data: data, fallbackPeriod: input.period) {
            return generated
        }
    } catch {
        return deterministicFinanceReport(period: input.period, snapshot: snapshot)
    }

    return deterministicFinanceReport(period: input.period, snapshot: snapshot)
}

private struct OpenAIReportPayload: Decodable {
    struct Section: Decodable {
        let heading: String
        let body: String
        let evidenceRefs: [String]
    }

    let title: String
    let period: String
    let sections: [Section]
    let decisionsRequired: [String]
}

private func parseOpenAIReport(data: Data, fallbackPeriod: String) throws -> FinanceReportDTO? {
    let object = try JSONSerialization.jsonObject(with: data)
    guard let text = firstStructuredText(in: object),
          let payloadData = text.data(using: .utf8)
    else {
        return nil
    }
    let payload = try JSONDecoder().decode(OpenAIReportPayload.self, from: payloadData)
    return FinanceReportDTO(
        id: UUID(),
        title: payload.title,
        period: payload.period.isEmpty ? fallbackPeriod : payload.period,
        sections: payload.sections.map {
            ReportSectionDTO(id: UUID(), heading: $0.heading, body: $0.body, evidenceRefs: $0.evidenceRefs)
        },
        decisionsRequired: payload.decisionsRequired
    )
}

private func firstStructuredText(in value: Any) -> String? {
    if let dictionary = value as? [String: Any] {
        if let type = dictionary["type"] as? String,
           (type == "output_text" || type == "text"),
           let text = dictionary["text"] as? String
        {
            return text
        }
        for child in dictionary.values {
            if let found = firstStructuredText(in: child) {
                return found
            }
        }
    }
    if let array = value as? [Any] {
        for child in array {
            if let found = firstStructuredText(in: child) {
                return found
            }
        }
    }
    return nil
}

private func deterministicFinanceReport(period: String, snapshot: FinanceWorkspaceSnapshotDTO) -> FinanceReportDTO {
    let exceptions = snapshot.records.filter { $0.status == "escalated" || $0.confidence < 0.86 }
    return FinanceReportDTO(
        id: UUID(),
        title: "AI generated finance and governance brief",
        period: period,
        sections: [
            ReportSectionDTO(
                id: UUID(),
                heading: "Executive overview",
                body: "The governed backend prepared a board-ready view across ledger, compliance, grants, and approvals.",
                evidenceRefs: snapshot.evidence.map(\.fileName)
            ),
            ReportSectionDTO(
                id: UUID(),
                heading: "Exception control",
                body: "\(exceptions.count) records require human review before external release or filing.",
                evidenceRefs: exceptions.flatMap { record in
                    snapshot.evidence.filter { record.evidenceIds.contains($0.id) }.map(\.fileName)
                }
            )
        ],
        decisionsRequired: [
            "Approve escalated accounting records.",
            "Confirm compliance task owners and due dates.",
            "Approve board-pack release only after exception review."
        ]
    )
}

private func appendFinanceAudit(
    actor: String,
    action: String,
    object: String,
    rationale: String,
    id: UUID = UUID(),
    timestamp: Date = Date(),
    on db: Database
) async throws -> AuditEventDTO {
    let row = FinanceAuditEventRecord()
    row.id = id
    row.timestamp = timestamp
    row.actor = actor
    row.action = action
    row.object = object
    row.rationale = rationale
    try await row.save(on: db)
    return AuditEventDTO(id: id, timestamp: timestamp, actor: actor, action: action, object: object, rationale: rationale)
}

private func jsonString<T: Encodable>(_ value: T) throws -> String {
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601
    return String(decoding: try encoder.encode(value), as: UTF8.self)
}

private func jsonDecode<T: Decodable>(_ type: T.Type, from string: String) throws -> T {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    return try decoder.decode(T.self, from: Data(string.utf8))
}

private func staticFinanceSeed() -> FinanceWorkspaceSnapshotDTO {
    let now = Date(timeIntervalSince1970: 1_780_300_800)
    let calendar = Calendar(identifier: .gregorian)
    let invoiceEvidence = SourceEvidenceDTO(
        id: UUID(uuidString: "10000000-0000-4000-8000-000000000001")!,
        fileName: "Atlassian-May-2026.pdf",
        sourceType: "Supplier invoice",
        extractedText: "Atlassian cloud subscription, May 2026, GST included.",
        checksum: "sha256:7f4d-demo-atlassian",
        capturedAt: now
    )
    let grantEvidence = SourceEvidenceDTO(
        id: UUID(uuidString: "10000000-0000-4000-8000-000000000002")!,
        fileName: "Innovation-Grant-Agreement.pdf",
        sourceType: "Grant contract",
        extractedText: "Milestone 2 requires eligible expenditure report, payroll evidence, and board sign-off.",
        checksum: "sha256:91aa-demo-grant",
        capturedAt: now
    )
    let bankEvidence = SourceEvidenceDTO(
        id: UUID(uuidString: "10000000-0000-4000-8000-000000000003")!,
        fileName: "BankFeed-2026-05.csv",
        sourceType: "Bank feed",
        extractedText: "Stripe payout and payroll clearing transactions for May 2026.",
        checksum: "sha256:aa03-demo-bankfeed",
        capturedAt: now
    )
    let records = [
        AccountingRecordDTO(
            id: UUID(uuidString: "20000000-0000-4000-8000-000000000001")!,
            entityId: "WCS-AU",
            projectId: "OPS",
            counterparty: "Atlassian Pty Ltd",
            transactionDate: now,
            postingDate: now,
            documentType: "Supplier invoice",
            description: "Cloud collaboration tools for program delivery",
            amount: MoneyDTO(amount: 429, currency: "AUD"),
            taxCode: "GST",
            accountCode: "6200 Software subscriptions",
            costCenter: "Operations",
            fundingSource: nil,
            confidence: 0.94,
            evidenceIds: [invoiceEvidence.id],
            status: "suggested",
            rationale: "Supplier, invoice wording, and GST treatment match the software subscription policy."
        ),
        AccountingRecordDTO(
            id: UUID(uuidString: "20000000-0000-4000-8000-000000000002")!,
            entityId: "WCS-AU",
            projectId: "GRANT-INNOVATION",
            counterparty: "World Class Scholars Payroll",
            transactionDate: calendar.date(byAdding: .day, value: -5, to: now) ?? now,
            postingDate: now,
            documentType: "Grant payroll allocation",
            description: "Grant-funded engineering payroll allocation",
            amount: MoneyDTO(amount: 8400, currency: "AUD"),
            taxCode: "N-T",
            accountCode: "5100 Salaries and wages",
            costCenter: "Product",
            fundingSource: "Innovation Grant",
            confidence: 0.78,
            evidenceIds: [grantEvidence.id, bankEvidence.id],
            status: "escalated",
            rationale: "Eligible-cost rule requires payroll support and grant manager approval before posting."
        )
    ]
    let tasks = [
        ComplianceTaskDTO(
            id: UUID(uuidString: "30000000-0000-4000-8000-000000000001")!,
            jurisdiction: "Australia",
            regime: "Tax",
            obligation: "Prepare June quarter BAS workpaper",
            dueDate: calendar.date(byAdding: .day, value: 28, to: now) ?? now,
            owner: "Finance Manager",
            severity: "high",
            evidenceRequired: ["GST detail report", "Bank reconciliation", "Approved ledger exceptions"],
            status: "inProgress",
            recommendedAction: "Resolve escalated GST and payroll records before adviser review."
        )
    ]
    let milestone = GrantMilestoneDTO(
        id: UUID(uuidString: "50000000-0000-4000-8000-000000000001")!,
        title: "Milestone 2 acquittal pack",
        dueDate: calendar.date(byAdding: .day, value: 42, to: now) ?? now,
        requiredEvidence: ["Payroll allocation report", "Eligible cost schedule", "Board sign-off"],
        trancheAmount: MoneyDTO(amount: 25000, currency: "AUD")
    )
    let report = FinanceReportDTO(
        id: UUID(uuidString: "60000000-0000-4000-8000-000000000001")!,
        title: "Monthly finance and governance brief",
        period: "May 2026",
        sections: [
            ReportSectionDTO(
                id: UUID(uuidString: "70000000-0000-4000-8000-000000000001")!,
                heading: "Executive overview",
                body: "Program revenue and grant spending are ready for management review.",
                evidenceRefs: [bankEvidence.fileName, grantEvidence.fileName]
            )
        ],
        decisionsRequired: ["Approve or reject grant payroll allocation."]
    )
    return FinanceWorkspaceSnapshotDTO(
        evidence: [invoiceEvidence, grantEvidence, bankEvidence],
        records: records,
        complianceTasks: tasks,
        governanceEvents: staticGovernanceEvents(),
        grants: [
            GrantAgreementDTO(
                id: UUID(uuidString: "40000000-0000-4000-8000-000000000001")!,
                grantName: "Innovation Grant",
                fundingBody: "State innovation program",
                startDate: calendar.date(byAdding: .month, value: -3, to: now) ?? now,
                endDate: calendar.date(byAdding: .month, value: 9, to: now) ?? now,
                eligibleCostRules: ["Payroll must map to approved project staff.", "Software costs require invoice evidence."],
                milestones: [milestone],
                reportingDeadlines: [milestone.dueDate]
            )
        ],
        auditTrail: [
            AuditEventDTO(
                id: UUID(uuidString: "80000000-0000-4000-8000-000000000001")!,
                timestamp: now,
                actor: "system",
                action: "Loaded backend finance workspace",
                object: "World Class Scholars AU pilot",
                rationale: "Database seed created governed finance operating data."
            )
        ],
        policyPacks: [
            PolicyPackDTO(
                id: UUID(uuidString: "90000000-0000-4000-8000-000000000010")!,
                title: "Founder governance pack",
                controls: ["Company constitution", "Founder IP assignment", "Board charter", "SaaS terms", "Privacy and security policies"],
                reviewer: "Board of Directors",
                status: "Generated from WCS-GOV-FOUNDER-PACK"
            ),
            PolicyPackDTO(
                id: UUID(uuidString: "90000000-0000-4000-8000-000000000001")!,
                title: "Australian tax pack",
                controls: ["GST/BAS workflow", "PAYG withholding checklist", "Record retention"],
                reviewer: "External accountant",
                status: "Draft for adviser validation"
            )
        ],
        reports: [report]
    )
}

private func staticGovernanceEvents() -> [GovernanceEventDTO] {
    [
        GovernanceEventDTO(
            id: UUID(uuidString: "a0000000-0000-4000-8000-000000000001")!,
            eventType: "Board resolution",
            meetingDate: Date(timeIntervalSince1970: 1_779_436_800),
            resolutionText: "Approve supervised finance-agent pilot with mandatory human approval for filings, tax, grants, cap table, and board reports.",
            approvers: ["Chair", "Founder", "Finance Director"],
            relatedRecords: [
                UUID(uuidString: "20000000-0000-4000-8000-000000000001")!,
                UUID(uuidString: "20000000-0000-4000-8000-000000000002")!
            ],
            followUpTasks: [UUID(uuidString: "30000000-0000-4000-8000-000000000001")!],
            explainabilityNote: "The control model preserves accountability by separating preparer, reviewer, and approver actions."
        )
    ]
}

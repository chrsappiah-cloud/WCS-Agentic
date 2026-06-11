//
//  LegalDeepSeekWorkspace.swift
//  WCS-Agentic
//

import Combine
import Foundation

struct LegalDeepSeekEngine {
    let runtimeMode: LegalDeepSeekRuntimeMode
    let modelName: String

    init(
        runtimeMode: LegalDeepSeekRuntimeMode = .localOffline,
        modelName: String = LegalDeepSeekPromptLibrary.modelName
    ) {
        self.runtimeMode = runtimeMode
        self.modelName = modelName
    }

    func invocation(
        for matter: LegalMatter,
        template: LegalDeepSeekPromptTemplate,
        evidence: [SourceEvidence],
        additionalContext: String = ""
    ) -> LegalDeepSeekInvocation {
        let evidenceDigest = evidence.map {
            "- \($0.fileName) [\($0.sourceType)]: \($0.extractedText)"
        }.joined(separator: "\n")

        let user = """
        Matter: \(matter.name)
        Client reference: \(matter.clientReference)
        Jurisdiction: \(matter.jurisdiction.isEmpty ? "Not supplied" : matter.jurisdiction)
        Practice area: \(matter.practiceArea.rawValue)
        Confidentiality: \(matter.confidentialityLevel)

        Objective:
        \(matter.objective)

        Facts:
        \(matter.facts)

        Evidence:
        \(evidenceDigest.isEmpty ? "No evidence supplied." : evidenceDigest)

        Additional context:
        \(additionalContext.isEmpty ? "None." : additionalContext)

        Task:
        \(template.userPrompt)
        """

        return LegalDeepSeekInvocation(
            system: LegalDeepSeekPromptLibrary.systemGuardrails,
            developer: LegalDeepSeekPromptLibrary.developerGuardrails,
            user: user,
            outputContract: template.outputContract,
            runtimeMode: runtimeMode,
            modelName: modelName
        )
    }

    func draftReview(
        for matter: LegalMatter,
        template: LegalDeepSeekPromptTemplate,
        evidence: [SourceEvidence],
        additionalContext: String = ""
    ) -> LegalDeepSeekReview {
        let findings = buildFindings(
            matter: matter,
            template: template,
            evidence: evidence,
            additionalContext: additionalContext
        )
        let status: LegalDeepSeekReviewStatus = findings.contains { $0.riskLevel == .critical }
            ? .blocked
            : .lawyerReviewRequired

        return LegalDeepSeekReview(
            id: UUID(),
            matterId: matter.id,
            createdAt: Date(),
            runtimeMode: runtimeMode,
            modelName: modelName,
            promptTitle: template.title,
            executiveSummary: executiveSummary(for: matter, template: template, findings: findings),
            findings: findings,
            disclaimers: [
                "AI-generated legal work product for lawyer review only.",
                "Not legal advice and not suitable for client delivery, filing, settlement, or signature until approved by a qualified lawyer.",
                "Case law, statutes, court rules, deadlines, and jurisdiction-specific claims must be verified in authoritative legal sources."
            ],
            status: status
        )
    }

    static func supervisedAgentSummary(for prompt: String) -> String {
        """
        [Legal DeepSeek] Governed draft (lawyer review required)

        Prompt understood: \(prompt.prefix(220))\(prompt.count > 220 ? "..." : "")

        Routing:
        - Use local/offline or self-hosted DeepSeek-R1 for confidential legal material.
        - Apply evidence-bounded reasoning and keep assumptions visible.
        - Verify all case law, statutes, deadlines, and jurisdiction-specific claims before use.

        Status: lawyer review required. The sub-agent will not produce final legal advice, file documents, contact clients, or approve settlement terms without a human legal approval gate.
        """
    }

    private func buildFindings(
        matter: LegalMatter,
        template: LegalDeepSeekPromptTemplate,
        evidence: [SourceEvidence],
        additionalContext: String
    ) -> [LegalDeepSeekFinding] {
        var findings: [LegalDeepSeekFinding] = []

        if matter.needsJurisdictionReview {
            findings.append(
                LegalDeepSeekFinding(
                    id: UUID(),
                    title: "Jurisdiction missing",
                    riskLevel: .critical,
                    summary: "The matter does not identify a governing jurisdiction, so enforceability, compliance, remedies, and procedural points cannot be assessed reliably.",
                    recommendedAction: "Capture governing law, forum, client location, counterparty location, and any cross-border facts before using the draft.",
                    evidenceRefs: [],
                    needsCitationVerification: true
                )
            )
        }

        if matter.isHighlyConfidential && runtimeMode == .cloudPrototype {
            findings.append(
                LegalDeepSeekFinding(
                    id: UUID(),
                    title: "Confidential data should not use cloud prototype mode",
                    riskLevel: .critical,
                    summary: "The matter is marked confidential or privileged, but the selected runtime sends prompts outside a controlled local/self-hosted environment.",
                    recommendedAction: "Switch to local offline or self-hosted DeepSeek before processing privileged material.",
                    evidenceRefs: [],
                    needsCitationVerification: false
                )
            )
        }

        if evidence.isEmpty {
            findings.append(
                LegalDeepSeekFinding(
                    id: UUID(),
                    title: "Evidence bundle missing",
                    riskLevel: .high,
                    summary: "The sub-agent cannot ground the review in supplied documents, making hallucination and unsupported assumption risk higher.",
                    recommendedAction: "Attach contracts, policies, pleadings, correspondence, transcripts, or source extracts before relying on the output.",
                    evidenceRefs: [],
                    needsCitationVerification: true
                )
            )
        }

        switch template.practiceArea {
        case .contractAnalysis:
            findings.append(
                LegalDeepSeekFinding(
                    id: UUID(),
                    title: "Contract clause risk map required",
                    riskLevel: .high,
                    summary: "The review should focus on ambiguity, one-sided clauses, missing protections, indemnity, liability caps, termination, renewal, dispute resolution, IP, confidentiality, and force majeure.",
                    recommendedAction: "Prepare a negotiation table with preferred drafting positions and send it to counsel for approval.",
                    evidenceRefs: evidence.map(\.fileName),
                    needsCitationVerification: true
                )
            )
        case .litigationStrategy:
            findings.append(
                LegalDeepSeekFinding(
                    id: UUID(),
                    title: "Litigation claims require authority verification",
                    riskLevel: .high,
                    summary: "Arguments, defenses, procedural options, settlement strategy, and witness questions are high-impact legal work that require verified authorities and lawyer judgement.",
                    recommendedAction: "Check every authority, deadline, pleading rule, evidence issue, and settlement assumption in a trusted legal research system.",
                    evidenceRefs: evidence.map(\.fileName),
                    needsCitationVerification: true
                )
            )
        case .complianceRisk:
            findings.append(
                LegalDeepSeekFinding(
                    id: UUID(),
                    title: "Compliance controls need current-source review",
                    riskLevel: .high,
                    summary: "Regulatory obligations can change quickly and differ by region, sector, data category, and entity status.",
                    recommendedAction: "Turn findings into an obligations register with owners, evidence, due dates, and counsel/compliance sign-off.",
                    evidenceRefs: evidence.map(\.fileName),
                    needsCitationVerification: true
                )
            )
        case .legalWriting:
            findings.append(
                LegalDeepSeekFinding(
                    id: UUID(),
                    title: "Draft is not client-ready",
                    riskLevel: .medium,
                    summary: "The output can accelerate summarization and drafting but should preserve uncertainty, assumptions, and source limitations.",
                    recommendedAction: "Review legal accuracy, tone, citations, defined terms, and client suitability before use.",
                    evidenceRefs: evidence.map(\.fileName),
                    needsCitationVerification: true
                )
            )
        case .clientConsultation:
            findings.append(
                LegalDeepSeekFinding(
                    id: UUID(),
                    title: "Client engagement controls required",
                    riskLevel: .high,
                    summary: "Intake and correspondence can create reliance risk if they imply legal advice or an attorney-client relationship before conflict checks and engagement terms.",
                    recommendedAction: "Add conflict-check, engagement-letter, urgent-deadline, and no-advice disclaimers before sending client-facing material.",
                    evidenceRefs: evidence.map(\.fileName),
                    needsCitationVerification: true
                )
            )
        case .lawFirmMarketing:
            findings.append(
                LegalDeepSeekFinding(
                    id: UUID(),
                    title: "Legal advertising review required",
                    riskLevel: .medium,
                    summary: "Marketing copy must avoid outcome guarantees, misleading specialization claims, and individualized legal advice.",
                    recommendedAction: "Review content against local legal advertising rules and add educational-purpose caveats.",
                    evidenceRefs: evidence.map(\.fileName),
                    needsCitationVerification: false
                )
            )
        case .legalInnovation:
            findings.append(
                LegalDeepSeekFinding(
                    id: UUID(),
                    title: "AI governance controls required",
                    riskLevel: .high,
                    summary: "Legal AI workflows must manage confidentiality, hallucination, bias, auditability, model-hosting, and human oversight risks.",
                    recommendedAction: "Adopt local/self-hosted processing for privileged data, citation checks, audit logs, role controls, and explicit lawyer approval gates.",
                    evidenceRefs: evidence.map(\.fileName),
                    needsCitationVerification: false
                )
            )
        }

        if additionalContext.localizedCaseInsensitiveContains("deadline")
            || matter.facts.localizedCaseInsensitiveContains("deadline")
            || matter.objective.localizedCaseInsensitiveContains("file")
            || matter.objective.localizedCaseInsensitiveContains("settlement") {
            findings.append(
                LegalDeepSeekFinding(
                    id: UUID(),
                    title: "Irreversible legal action gate",
                    riskLevel: .critical,
                    summary: "The matter mentions a deadline, filing, or settlement-related action that could materially affect rights.",
                    recommendedAction: "Block autonomous action and route to qualified counsel immediately.",
                    evidenceRefs: evidence.map(\.fileName),
                    needsCitationVerification: true
                )
            )
        }

        return findings
    }

    private func executiveSummary(
        for matter: LegalMatter,
        template: LegalDeepSeekPromptTemplate,
        findings: [LegalDeepSeekFinding]
    ) -> String {
        let highestRisk = findings.contains { $0.riskLevel == .critical }
            ? "critical"
            : findings.contains { $0.riskLevel == .high } ? "high" : "controlled"
        return """
        \(template.title) prepared for \(matter.name) in \(matter.jurisdiction.isEmpty ? "an unspecified jurisdiction" : matter.jurisdiction). The draft uses DeepSeek-style structured reasoning for \(matter.practiceArea.rawValue.lowercased()) and identifies \(highestRisk) review risk. Human legal approval is required before any client-facing, filing, settlement, or signature use.
        """
    }
}

@MainActor
final class LegalDeepSeekWorkspace: ObservableObject {
    @Published private(set) var matters: [LegalMatter]
    @Published private(set) var evidence: [SourceEvidence]
    @Published private(set) var reviews: [LegalDeepSeekReview]
    @Published private(set) var auditTrail: [AuditEvent]
    @Published var runtimeMode: LegalDeepSeekRuntimeMode
    @Published var selectedPracticeArea: LegalDeepSeekPracticeArea
    @Published var selectedTemplateID: String
    @Published var additionalContext: String = ""

    private var engine: LegalDeepSeekEngine {
        LegalDeepSeekEngine(runtimeMode: runtimeMode)
    }

    init(seed: LegalDeepSeekSeed = .demo) {
        matters = seed.matters
        evidence = seed.evidence
        reviews = seed.reviews
        auditTrail = seed.auditTrail
        runtimeMode = .localOffline
        selectedPracticeArea = .contractAnalysis
        selectedTemplateID = LegalDeepSeekPromptLibrary.templates.first?.id ?? ""
    }

    var templatesForSelectedArea: [LegalDeepSeekPromptTemplate] {
        LegalDeepSeekPromptLibrary.templates(for: selectedPracticeArea)
    }

    var selectedTemplate: LegalDeepSeekPromptTemplate {
        if let template = LegalDeepSeekPromptLibrary.templates.first(where: { $0.id == selectedTemplateID }) {
            return template
        }
        return templatesForSelectedArea.first ?? LegalDeepSeekPromptLibrary.templates[0]
    }

    var activeMatters: [LegalMatter] {
        matters.filter { $0.reviewStatus != .approved }
    }

    var lawyerReviewCount: Int {
        reviews.filter(\.humanReviewRequired).count + matters.filter { $0.reviewStatus == .lawyerReviewRequired }.count
    }

    var highRiskCount: Int {
        reviews.reduce(0) { count, review in
            count + review.findings.filter { $0.riskLevel == .high || $0.riskLevel == .critical }.count
        }
    }

    var runtimeRecommendation: String {
        switch runtimeMode {
        case .localOffline:
            return "Best for privileged or confidential legal work."
        case .selfHostedEndpoint:
            return "Acceptable for controlled firm infrastructure with logging and encryption."
        case .cloudPrototype:
            return "Prototype only. Do not process privileged or client-sensitive material."
        }
    }

    func matter(for area: LegalDeepSeekPracticeArea? = nil) -> LegalMatter? {
        let area = area ?? selectedPracticeArea
        return matters.first { $0.practiceArea == area } ?? matters.first
    }

    func evidence(for matter: LegalMatter) -> [SourceEvidence] {
        evidence.filter { matter.sourceIds.contains($0.id) }
    }

    func buildInvocation(for matter: LegalMatter) -> LegalDeepSeekInvocation {
        engine.invocation(
            for: matter,
            template: selectedTemplate,
            evidence: evidence(for: matter),
            additionalContext: additionalContext
        )
    }

    @discardableResult
    func runSelectedReview(actor: String = "legal.operator@worldclassscholars.test") -> LegalDeepSeekReview? {
        guard let matter = matter(for: selectedPracticeArea) else { return nil }
        let template = selectedTemplate.practiceArea == matter.practiceArea
            ? selectedTemplate
            : LegalDeepSeekPromptLibrary.templates(for: matter.practiceArea).first ?? selectedTemplate
        let review = engine.draftReview(
            for: matter,
            template: template,
            evidence: evidence(for: matter),
            additionalContext: additionalContext
        )
        reviews.insert(review, at: 0)
        updateMatter(matter.id, status: review.status)
        log(
            actor: actor,
            action: "Generated Legal DeepSeek draft",
            object: matter.name,
            rationale: "Created \(template.title) using \(runtimeMode.rawValue); lawyer review gate remains active."
        )
        return review
    }

    func approve(_ review: LegalDeepSeekReview, actor: String = "legal.counsel@worldclassscholars.test") {
        guard let index = reviews.firstIndex(where: { $0.id == review.id }) else { return }
        reviews[index].status = .approved
        updateMatter(review.matterId, status: .approved)
        log(
            actor: actor,
            action: "Approved Legal DeepSeek draft",
            object: review.promptTitle,
            rationale: "Qualified legal review completed before use."
        )
    }

    func blockCloudForConfidentialMatter(actor: String = "legal.operator@worldclassscholars.test") {
        runtimeMode = .localOffline
        log(
            actor: actor,
            action: "Switched legal runtime to local offline",
            object: "Legal DeepSeek runtime",
            rationale: "Confidential and privileged matters require local or self-hosted processing."
        )
    }

    func setPracticeArea(_ area: LegalDeepSeekPracticeArea) {
        selectedPracticeArea = area
        selectedTemplateID = LegalDeepSeekPromptLibrary.templates(for: area).first?.id ?? selectedTemplateID
    }

    private func updateMatter(_ id: UUID, status: LegalDeepSeekReviewStatus) {
        guard let index = matters.firstIndex(where: { $0.id == id }) else { return }
        matters[index].reviewStatus = status
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

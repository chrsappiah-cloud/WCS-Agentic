//
//  LegalDeepSeekModels.swift
//  WCS-Agentic
//

import Foundation

enum LegalDeepSeekPracticeArea: String, Codable, CaseIterable, Identifiable {
    case contractAnalysis = "Contract analysis"
    case litigationStrategy = "Litigation strategy"
    case complianceRisk = "Compliance and risk"
    case legalWriting = "Legal writing"
    case clientConsultation = "Client consultation"
    case lawFirmMarketing = "Law firm marketing"
    case legalInnovation = "Legal innovation"

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .contractAnalysis: return "doc.text.magnifyingglass"
        case .litigationStrategy: return "building.columns"
        case .complianceRisk: return "checkmark.shield"
        case .legalWriting: return "pencil.and.outline"
        case .clientConsultation: return "person.2.wave.2"
        case .lawFirmMarketing: return "megaphone"
        case .legalInnovation: return "sparkles"
        }
    }
}

enum LegalDeepSeekRuntimeMode: String, Codable, CaseIterable, Identifiable {
    case localOffline = "Local offline"
    case selfHostedEndpoint = "Self-hosted endpoint"
    case cloudPrototype = "Cloud prototype"

    var id: String { rawValue }
}

enum LegalDeepSeekRiskLevel: String, Codable, CaseIterable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    case critical = "Critical"
}

enum LegalDeepSeekReviewStatus: String, Codable, CaseIterable {
    case draft = "Draft"
    case lawyerReviewRequired = "Lawyer review required"
    case approved = "Approved"
    case blocked = "Blocked"
}

struct LegalDeepSeekPromptTemplate: Codable, Identifiable, Hashable {
    let id: String
    let practiceArea: LegalDeepSeekPracticeArea
    let title: String
    let purpose: String
    let userPrompt: String
    let outputContract: String
    let riskControls: [String]
}

struct LegalMatter: Codable, Identifiable, Hashable {
    let id: UUID
    let name: String
    let clientReference: String
    let jurisdiction: String
    let practiceArea: LegalDeepSeekPracticeArea
    let confidentialityLevel: String
    let facts: String
    let objective: String
    let sourceIds: [UUID]
    var reviewStatus: LegalDeepSeekReviewStatus

    var needsJurisdictionReview: Bool {
        jurisdiction.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var isHighlyConfidential: Bool {
        confidentialityLevel.localizedCaseInsensitiveContains("privileged")
            || confidentialityLevel.localizedCaseInsensitiveContains("confidential")
    }
}

struct LegalDeepSeekFinding: Codable, Identifiable, Hashable {
    let id: UUID
    let title: String
    let riskLevel: LegalDeepSeekRiskLevel
    let summary: String
    let recommendedAction: String
    let evidenceRefs: [String]
    let needsCitationVerification: Bool
}

struct LegalDeepSeekReview: Codable, Identifiable, Hashable {
    let id: UUID
    let matterId: UUID
    let createdAt: Date
    let runtimeMode: LegalDeepSeekRuntimeMode
    let modelName: String
    let promptTitle: String
    let executiveSummary: String
    let findings: [LegalDeepSeekFinding]
    let disclaimers: [String]
    var status: LegalDeepSeekReviewStatus

    var humanReviewRequired: Bool {
        status == .lawyerReviewRequired
            || findings.contains { $0.riskLevel == .high || $0.riskLevel == .critical || $0.needsCitationVerification }
    }
}

struct LegalDeepSeekInvocation: Codable, Hashable {
    let system: String
    let developer: String
    let user: String
    let outputContract: String
    let runtimeMode: LegalDeepSeekRuntimeMode
    let modelName: String
}

struct LegalDeepSeekSeed {
    let matters: [LegalMatter]
    let evidence: [SourceEvidence]
    let reviews: [LegalDeepSeekReview]
    let auditTrail: [AuditEvent]

    nonisolated static var demo: LegalDeepSeekSeed {
        let now = Date()
        let contractEvidence = SourceEvidence(
            id: UUID(),
            fileName: "Supplier-Services-Agreement.pdf",
            sourceType: "Commercial contract",
            extractedText: "Services agreement includes automatic renewal, broad indemnity, limitation of liability, and force majeure language.",
            checksum: "sha256:legal-demo-contract",
            capturedAt: now
        )
        let complianceEvidence = SourceEvidence(
            id: UUID(),
            fileName: "Privacy-Policy-Draft.docx",
            sourceType: "Policy draft",
            extractedText: "Draft privacy policy covers collection, use, disclosure, retention, and cross-border transfer controls.",
            checksum: "sha256:legal-demo-policy",
            capturedAt: now
        )
        let litigationEvidence = SourceEvidence(
            id: UUID(),
            fileName: "Matter-Facts-Memo.txt",
            sourceType: "Matter facts",
            extractedText: "Counterparty missed delivery milestones, continued partial performance, and disputes whether delay was excused.",
            checksum: "sha256:legal-demo-facts",
            capturedAt: now
        )

        let matters = [
            LegalMatter(
                id: UUID(),
                name: "Supplier services agreement review",
                clientReference: "WCS-AU",
                jurisdiction: "Australia",
                practiceArea: .contractAnalysis,
                confidentialityLevel: "Privileged and confidential",
                facts: "Review a supplier services agreement for renewal, indemnity, limitation of liability, dispute resolution, and force majeure risk before signature.",
                objective: "Identify risky clauses, recommend negotiation positions, and prepare a lawyer-review checklist.",
                sourceIds: [contractEvidence.id],
                reviewStatus: .draft
            ),
            LegalMatter(
                id: UUID(),
                name: "Privacy compliance gap scan",
                clientReference: "WCS-AU",
                jurisdiction: "Australia",
                practiceArea: .complianceRisk,
                confidentialityLevel: "Confidential",
                facts: "Assess a privacy policy draft against consent, data retention, cross-border transfer, breach response, and vendor controls.",
                objective: "Create a compliance gap table for counsel and governance review.",
                sourceIds: [complianceEvidence.id],
                reviewStatus: .draft
            ),
            LegalMatter(
                id: UUID(),
                name: "Contract delay dispute strategy",
                clientReference: "WCS-AU",
                jurisdiction: "Australia",
                practiceArea: .litigationStrategy,
                confidentialityLevel: "Privileged and confidential",
                facts: "Counterparty missed delivery milestones but claims the delay was excused by market disruption while continuing partial performance.",
                objective: "Prepare argument options, counterarguments, evidence gaps, and settlement considerations for lawyer review.",
                sourceIds: [litigationEvidence.id],
                reviewStatus: .draft
            ),
        ]

        return LegalDeepSeekSeed(
            matters: matters,
            evidence: [contractEvidence, complianceEvidence, litigationEvidence],
            reviews: [],
            auditTrail: [
                AuditEvent(
                    id: UUID(),
                    timestamp: now,
                    actor: "legal.operator@worldclassscholars.test",
                    action: "Loaded Legal DeepSeek sub-agent",
                    object: "Prompt catalog",
                    rationale: "Initialized offline-first legal AI workspace with lawyer review gates."
                )
            ]
        )
    }
}

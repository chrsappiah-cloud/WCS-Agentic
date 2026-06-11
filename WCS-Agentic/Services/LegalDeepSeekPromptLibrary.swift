//
//  LegalDeepSeekPromptLibrary.swift
//  WCS-Agentic
//

import Foundation

enum LegalDeepSeekPromptLibrary {
    static let modelName = "DeepSeek-R1 legal reasoning profile"

    static let systemGuardrails = """
    You are the Legal DeepSeek sub-agent inside WCS-Agentic.
    You support lawyers, in-house counsel, compliance officers, legal researchers, and law firms with structured legal drafting, review, summarization, and strategy work.
    You are not a lawyer, you do not create final legal advice, and every output must require review by a qualified legal professional.
    Prefer local or self-hosted execution for confidential, privileged, client-sensitive, or regulated material.
    Do not invent case law, statutes, citations, regulatory dates, filing deadlines, court rules, or jurisdiction-specific requirements.
    If a legal source is not supplied in the matter bundle, mark it as citation verification required.
    """

    static let developerGuardrails = """
    Use evidence-bounded reasoning:
    1. Restate the matter objective and jurisdiction.
    2. Separate supplied facts from assumptions.
    3. Identify risks, missing facts, and document gaps.
    4. Provide practical next steps for counsel.
    5. Mark all litigation, regulatory, and citation-sensitive claims for verification.
    6. Block final client-facing advice until a human lawyer approves it.
    """

    static let templates: [LegalDeepSeekPromptTemplate] = [
        LegalDeepSeekPromptTemplate(
            id: "contract-risk-review",
            practiceArea: .contractAnalysis,
            title: "Contract risk review",
            purpose: "Analyze agreements for ambiguous, one-sided, missing, unenforceable, or commercially risky clauses.",
            userPrompt: "Review the supplied contract facts and evidence for the stated jurisdiction. Identify risky clauses, explain why each risk matters, suggest negotiation language, and flag issues that require lawyer review.",
            outputContract: "Return Markdown with: executive summary, risk table, clause observations, negotiation recommendations, missing evidence, citation verification checklist, and lawyer approval gate.",
            riskControls: [
                "Do not certify enforceability.",
                "Do not draft final execution-ready clauses without lawyer review.",
                "Flag governing law, dispute resolution, indemnity, liability cap, renewal, termination, IP, confidentiality, and force majeure issues."
            ]
        ),
        LegalDeepSeekPromptTemplate(
            id: "litigation-strategy",
            practiceArea: .litigationStrategy,
            title: "Litigation strategy and counterarguments",
            purpose: "Structure case theory, arguments, weaknesses, evidence gaps, settlement options, and trial preparation questions.",
            userPrompt: "Using only the supplied matter facts and evidence, prepare a litigation strategy memo. Compare plausible arguments, identify counterarguments, list evidence gaps, and mark any citation-dependent point for verification.",
            outputContract: "Return Markdown with: case posture, strongest arguments, weaknesses, counterarguments, evidence plan, settlement/ADR considerations, citation verification items, and lawyer approval gate.",
            riskControls: [
                "Do not predict outcomes as certain.",
                "Do not invent authorities.",
                "Treat court deadlines, procedural rules, witness handling, and settlement advice as high-risk lawyer-review items."
            ]
        ),
        LegalDeepSeekPromptTemplate(
            id: "compliance-gap-analysis",
            practiceArea: .complianceRisk,
            title: "Regulatory compliance gap analysis",
            purpose: "Assess policies, workflows, and transactions for regulatory, privacy, employment, finance, AI, and governance risks.",
            userPrompt: "Assess the supplied policy, procedure, or transaction against the named compliance regime. Identify gaps, severity, controls, owner actions, and evidence required for counsel or compliance sign-off.",
            outputContract: "Return Markdown with: regime scope, gap table, risk severity, mitigation controls, owner checklist, evidence required, external-source verification items, and lawyer approval gate.",
            riskControls: [
                "Do not state that compliance is complete.",
                "Mark fast-changing laws and regional requirements for verification.",
                "Escalate privacy, AML, sanctions, employment, healthcare, financial, AI, and child-safety issues."
            ]
        ),
        LegalDeepSeekPromptTemplate(
            id: "legal-writing-summary",
            practiceArea: .legalWriting,
            title: "Legal writing and summarization",
            purpose: "Summarize long legal documents, draft memos, prepare client-friendly explanations, and refine legal writing.",
            userPrompt: "Summarize or draft the requested legal document using supplied facts only. Keep legal uncertainty visible, explain assumptions, and convert dense wording into a structured lawyer-review draft.",
            outputContract: "Return Markdown with: plain-language summary, legal issue map, draft text, assumptions, unresolved questions, verification list, and lawyer approval gate.",
            riskControls: [
                "Do not remove legally meaningful qualifications.",
                "Do not make client-facing recommendations final.",
                "Flag any unsupported legal rule, citation, filing deadline, or jurisdictional statement."
            ]
        ),
        LegalDeepSeekPromptTemplate(
            id: "client-intake-case-management",
            practiceArea: .clientConsultation,
            title: "Client intake and case management",
            purpose: "Create intake questionnaires, case assessment matrices, correspondence drafts, and workflow checklists.",
            userPrompt: "Prepare a structured client intake, case assessment, or correspondence workflow for the described matter. Separate client-facing language from internal lawyer notes.",
            outputContract: "Return Markdown with: intake questions, document checklist, risk screen, case workflow, client correspondence draft, internal notes, and lawyer approval gate.",
            riskControls: [
                "Do not create an attorney-client relationship statement.",
                "Include conflict-check and engagement-letter reminders.",
                "Escalate urgent deadlines, criminal exposure, immigration status, family violence, and vulnerable-client concerns."
            ]
        ),
        LegalDeepSeekPromptTemplate(
            id: "law-firm-marketing-seo",
            practiceArea: .lawFirmMarketing,
            title: "Law firm marketing and SEO",
            purpose: "Draft educational blog, website, newsletter, and social content while preserving legal ethics and advertising controls.",
            userPrompt: "Create educational legal marketing content for the target audience and jurisdiction. Keep it general information, avoid guarantees, and include review notes for lawyer and advertising compliance checks.",
            outputContract: "Return Markdown with: audience, content draft, SEO metadata, compliance notes, claims to verify, jurisdiction caveat, and lawyer approval gate.",
            riskControls: [
                "Do not promise outcomes.",
                "Do not imply specialist accreditation unless supplied.",
                "Keep content educational rather than individualized legal advice."
            ]
        ),
        LegalDeepSeekPromptTemplate(
            id: "legal-ai-governance",
            practiceArea: .legalInnovation,
            title: "Legal AI governance review",
            purpose: "Assess confidentiality, hallucination, bias, model-hosting, and human oversight risks before using AI in legal workflows.",
            userPrompt: "Review this proposed legal AI workflow for confidentiality, hallucination, bias, auditability, human approval, and deployment-mode risks. Recommend governance controls before production use.",
            outputContract: "Return Markdown with: workflow summary, risk register, deployment recommendation, required controls, prohibited uses, audit events, and approval checklist.",
            riskControls: [
                "Prefer local offline or self-hosted processing for privileged data.",
                "Require citation verification and lawyer approval.",
                "Block autonomous filing, settlement, legal advice, or client communication without approval."
            ]
        ),
    ]

    static var playbookSummary: [String] {
        [
            "Contract analysis and drafting: risk identification, negotiation, enforceability, breach, remedies, dispute resolution, and industry-specific agreements.",
            "Litigation and case strategy: precedent analysis, argument development, witness preparation, settlement, ADR, jury selection, and trial narrative.",
            "Regulatory compliance and risk: audits, gap analysis, privacy, AML, employment, healthcare, financial services, AI governance, and cross-border trends.",
            "Legal writing and summarization: executive summaries, legal memos, opinion letters, contract drafting, policies, advocacy, and plain-language client explanations.",
            "Client consultation and case management: intake, viability screening, document checklists, legal strategy, client letters, and workflow automation.",
            "Law firm marketing and SEO: educational articles, website pages, metadata, social posts, newsletters, and advertising compliance checks.",
            "Legal innovation: confidentiality, hallucination risk, bias, lawyer oversight, local deployment, and responsible AI operations."
        ]
    }

    static func templates(for area: LegalDeepSeekPracticeArea) -> [LegalDeepSeekPromptTemplate] {
        templates.filter { $0.practiceArea == area }
    }
}

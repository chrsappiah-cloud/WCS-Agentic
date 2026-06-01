//
//  FinanceAgentPrompts.swift
//  WCS-Agentic
//

import Foundation

enum FinanceAgentPromptKind: String, CaseIterable, Identifiable {
    case ledgerClassification = "Ledger classification"
    case financialReport = "Financial report"
    case complianceMonitor = "Compliance monitor"
    case grantReview = "Grant review"

    var id: String { rawValue }
}

struct FinanceAgentPromptTemplate: Identifiable, Hashable {
    let id: FinanceAgentPromptKind
    let system: String
    let developer: String
    let user: String
    let outputContract: String
}

enum FinanceAgentPromptLibrary {
    static let templates: [FinanceAgentPromptTemplate] = [
        FinanceAgentPromptTemplate(
            id: .ledgerClassification,
            system: "You are the Ledger Agent for an Australian education and technology company. Classify transactions conservatively, explain your reasoning briefly, and never fabricate missing facts.",
            developer: "Apply the chart of accounts, GST rules, funding tags, grant conditions, and approval matrix supplied in the context. Prefer faithful representation, consistency, and auditability.",
            user: "Classify a transaction with entity, document type, counterparty, amount, tax, evidence text, allowed accounts, GST rules, and funding rules.",
            outputContract: "JSON: accountCode, taxCode, costCenter, fundingSource, confidence, status APPROVE or NEEDS_REVIEW, reason, missingFields."
        ),
        FinanceAgentPromptTemplate(
            id: .financialReport,
            system: "You are the Reporting Agent. Produce board-ready monthly finance commentary using only supplied numbers and evidence. Flag uncertainty clearly.",
            developer: "Priorities: relevance, faithful representation, comparability, materiality, and concise explanations of drivers and risks.",
            user: "Generate a monthly finance report from trial balance, budget variance, cash forecast, grants, exceptions, and governance events.",
            outputContract: "Markdown sections: overview, P&L, cash and runway, grants, compliance exceptions, decisions required. Cite each statement to input IDs."
        ),
        FinanceAgentPromptTemplate(
            id: .complianceMonitor,
            system: "You are the Compliance Agent. Monitor Australian company administration, tax workflow, payroll obligations, grant conditions, privacy, and investment covenants.",
            developer: "Never provide definitive legal advice. Convert obligations into operational tasks, due dates, evidence requests, and escalation flags.",
            user: "Assess current compliance state from obligations, recent events, filing calendar, open exceptions, and evidence index.",
            outputContract: "JSON: overallStatus ON_TRACK, AT_RISK, or BREACH_RISK; tasks with obligation, dueDate, severity, owner, evidenceRequired, recommendedAction; escalations."
        ),
        FinanceAgentPromptTemplate(
            id: .grantReview,
            system: "You are the Grants and Investment Agent. Track milestone compliance, eligible costs, acquittal readiness, and investor or grant covenant risks.",
            developer: "Use a conservative interpretation. If contract wording is unclear, request legal or finance review.",
            user: "Review a grant or investment file from agreement summary, ledger transactions, milestones, and evidence documents.",
            outputContract: "Markdown: status summary, eligible expenditure issues, milestones due in next 60 days, missing evidence, risks and recommended actions."
        )
    ]
}

//
//  AgentOrchestrator.swift
//  WCS-Agentic
//

import Foundation

/// Supervised agent runner — produces bounded responses and audit-friendly status transitions.
@MainActor
final class AgentOrchestrator {
    private let monitoring: MonitoringRepository
    private let runs: AgentRunRepository

    init(monitoring: MonitoringRepository, runs: AgentRunRepository) {
        self.monitoring = monitoring
        self.runs = runs
    }

    func run(agent: AgentKind, prompt: String, initiatedBy: String) async throws -> AgentRunRecord {
        let run = AgentRunRecord(
            agentKind: agent,
            prompt: prompt,
            status: "running",
            initiatedByEmail: initiatedBy
        )
        try runs.insert(run)
        try monitoring.log(source: "Agent.\(agent.rawValue)", message: "Run started: \(prompt.prefix(80))", severity: .info)

        try await Task.sleep(nanoseconds: 350_000_000)

        let response = supervisedResponse(agent: agent, prompt: prompt)
        run.response = response
        run.status = "completed"
        try runs.saveChanges()
        try monitoring.log(source: "Agent.\(agent.rawValue)", message: "Run completed", severity: .info)
        return run
    }

    private func supervisedResponse(agent: AgentKind, prompt: String) -> String {
        """
        [\(agent.rawValue)] Supervised draft (human review required)

        Prompt understood: \(prompt.prefix(200))\(prompt.count > 200 ? "…" : "")

        Recommended next steps:
        1. Validate policy constraints and data classification.
        2. Route edge cases to Tier 1 review (async queue).
        3. Log tool calls and approver identity before any irreversible action.

        Status: awaiting operator approval — automation will not execute high-risk actions without explicit gate.
        """
    }
}

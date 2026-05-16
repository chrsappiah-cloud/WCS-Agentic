//
//  AgentOrchestrator.swift
//  WCS-Agentic
//

import Foundation

/// Supervised agent runner — production workflows via platform orchestrator when available.
@MainActor
final class AgentOrchestrator {
    private let monitoring: MonitoringRepository
    private let runs: AgentRunRepository
    private let workflowCoordinator: WorkflowCoordinator
    private let sessions: WorkflowSessionRepository

    init(
        monitoring: MonitoringRepository,
        runs: AgentRunRepository,
        workflowCoordinator: WorkflowCoordinator,
        sessions: WorkflowSessionRepository
    ) {
        self.monitoring = monitoring
        self.runs = runs
        self.workflowCoordinator = workflowCoordinator
        self.sessions = sessions
    }

    func run(
        agent: AgentKind,
        prompt: String,
        participantEmail: String,
        documentHint: String,
        participantId: UUID?,
        courseId: String,
        role: String,
        initiatedBy: String
    ) async throws -> AgentRunRecord {
        let run = AgentRunRecord(
            agentKind: agent,
            prompt: prompt,
            status: "running",
            initiatedByEmail: initiatedBy
        )
        try runs.insert(run)
        try monitoring.log(source: "Agent.\(agent.rawValue)", message: "Run started: \(prompt.prefix(80))", severity: .info)

        if agent.usesPlatformOrchestrator {
            let session = try await workflowCoordinator.startProductionWorkflow(
                agent: agent,
                participantEmail: participantEmail,
                documentHint: documentHint,
                participantId: participantId,
                courseId: courseId,
                role: role,
                initiatedBy: initiatedBy,
                sessions: sessions,
                monitoring: monitoring
            )
            run.response = """
            Production workflow started on orchestrator.

            Session: \(session.platformSessionId)
            Status: \(session.status)
            Type: \(session.workflowType)

            Check Approvals for human gates and Monitor for platform audit events.
            """
            run.status = session.status.contains("awaiting") ? "awaiting_approval" : "completed"
        } else {
            try await Task.sleep(nanoseconds: 350_000_000)
            run.response = supervisedResponse(agent: agent, prompt: prompt)
            run.status = "completed"
        }

        try runs.saveChanges()
        try monitoring.log(source: "Agent.\(agent.rawValue)", message: "Run \(run.status)", severity: .info)
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

//
//  AgentsHubView.swift
//  WCS-Agentic
//

import SwiftData
import SwiftUI

struct AgentsHubView: View {
    @EnvironmentObject private var session: SessionManager
    @EnvironmentObject private var workflows: WorkflowCoordinator
    @Environment(\.modelContext) private var modelContext

    @State private var selectedAgent: AgentKind = .onboarding
    @State private var promptText = ""
    @State private var participantEmail = ""
    @State private var documentHint = "passport"
    @State private var selectedParticipantId: UUID?
    @State private var courseId = "course-leadership"
    @State private var isRunning = false
    @State private var lastRunMessage: String?
    @State private var orchestrator: AgentOrchestrator?

    @Query(sort: \AgentRunRecord.createdAt, order: .reverse) private var runs: [AgentRunRecord]
    @Query(sort: \WorkflowSessionRecord.createdAt, order: .reverse) private var platformSessions: [WorkflowSessionRecord]
    @Query(sort: \ParticipantRecord.createdAt, order: .reverse) private var participants: [ParticipantRecord]

    var body: some View {
        List {
            Section {
                AgenticHeroHeader(
                    title: "Agent Console",
                    subtitle: "Production workflows via orchestrator (onboarding, certificate, concierge) plus supervised local drafts for support and campaigns."
                )
                .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 8, trailing: 16))
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }

            if !session.isSignedIn {
                accessGateCard(
                    title: "Sign in required",
                    message: "Open Account to sign in before running agents."
                )
            } else if !session.canRunAgents {
                accessGateCard(
                    title: "Upgrade or role required",
                    message: "Pro/Trial subscription and Operator/Admin role are required to run agents."
                )
            } else {
                workflowFormSection
            }

            if !platformSessions.isEmpty {
                Section {
                    ForEach(platformSessions.prefix(10), id: \.id) { s in
                        GlassCard {
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Text(s.workflowType.capitalized)
                                        .font(.headline)
                                    Spacer()
                                    Text(s.status)
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(AgenticTheme.emerald)
                                }
                                Text(s.summary)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                    }
                } header: {
                    Text("Platform sessions")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .textCase(nil)
                }
            }

            Section {
                if runs.isEmpty {
                    Text("No agent runs yet.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(runs.prefix(20), id: \.id) { run in
                        GlassCard {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Label(run.agentKind.rawValue, systemImage: run.agentKind.systemImage)
                                        .font(.headline)
                                    Spacer()
                                    Text(run.status.uppercased())
                                        .font(.caption2.weight(.bold))
                                        .foregroundStyle(AgenticTheme.bronze)
                                }
                                Text(run.prompt)
                                    .font(.subheadline)
                                    .lineLimit(2)
                                if !run.response.isEmpty {
                                    Text(run.response)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(5)
                                }
                            }
                        }
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                    }
                }
            } header: {
                Text("Recent runs")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .textCase(nil)
            }
        }
        .scrollContentBackground(.hidden)
        .background(AgenticTheme.pageBackground.ignoresSafeArea())
        .navigationTitle("Agents")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            orchestrator = AgentOrchestrator(
                monitoring: MonitoringRepository(modelContext: modelContext),
                runs: AgentRunRepository(modelContext: modelContext),
                workflowCoordinator: workflows,
                sessions: WorkflowSessionRepository(modelContext: modelContext)
            )
            if participantEmail.isEmpty {
                participantEmail = "pilot@worldclassscholars.test"
            }
        }
    }

    @ViewBuilder
    private var workflowFormSection: some View {
        Section {
            Picker("Agent", selection: $selectedAgent) {
                ForEach(AgentKind.allCases, id: \.self) { kind in
                    Label(kind.rawValue, systemImage: kind.systemImage).tag(kind)
                }
            }
            .accessibilityIdentifier("agents.picker")

            if selectedAgent.usesPlatformOrchestrator {
                Label("Routed to platform orchestrator", systemImage: "network")
                    .font(.caption)
                    .foregroundStyle(AgenticTheme.emerald)
            }

            Text(selectedAgent.description)
                .font(.footnote)
                .foregroundStyle(.secondary)

            TextField("Participant email", text: $participantEmail)
                .textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)
                .accessibilityIdentifier("agents.participantEmail")

            if selectedAgent == .onboarding {
                Picker("Document", selection: $documentHint) {
                    Text("Passport").tag("passport")
                    Text("National ID").tag("national_id")
                }
            }

            if selectedAgent == .certificate || selectedAgent == .concierge {
                Picker("Participant", selection: $selectedParticipantId) {
                    Text("Select participant").tag(UUID?.none)
                    ForEach(participants, id: \.id) { p in
                        Text(p.fullName).tag(Optional(p.id))
                    }
                }
            }

            if selectedAgent == .certificate {
                TextField("Course ID", text: $courseId)
                    .accessibilityIdentifier("agents.courseId")
            }

            TextField("Notes / prompt…", text: $promptText, axis: .vertical)
                .lineLimit(2 ... 6)
                .accessibilityIdentifier("agents.promptField")

            Button {
                Task { await runAgent() }
            } label: {
                Label(isRunning ? "Running…" : runButtonTitle, systemImage: "play.circle.fill")
            }
            .disabled(isRunning || !canRun)
            .accessibilityIdentifier("agents.runButton")

            if let lastRunMessage {
                Text(lastRunMessage)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        } header: {
            Text("Production workflow")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.secondary)
                .textCase(nil)
        }
    }

    private var runButtonTitle: String {
        selectedAgent.usesPlatformOrchestrator ? "Start orchestrator workflow" : "Run supervised agent"
    }

    private var canRun: Bool {
        let emailOk = !participantEmail.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        switch selectedAgent {
        case .onboarding:
            return emailOk
        case .certificate, .concierge:
            return selectedParticipantId != nil
        case .support, .campaign:
            return !promptText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    }

    private func accessGateCard(title: String, message: String) -> some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 8) {
                Text(title).font(.headline)
                Text(message).font(.subheadline).foregroundStyle(.secondary)
            }
        }
        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
    }

    private func runAgent() async {
        guard let orchestrator, let email = session.currentUser?.email else { return }
        isRunning = true
        lastRunMessage = nil
        defer { isRunning = false }
        let role = session.isAdmin ? "admin" : "operator"
        let prompt = promptText.isEmpty ? "Start \(selectedAgent.rawValue) for \(participantEmail)" : promptText
        do {
            _ = try await orchestrator.run(
                agent: selectedAgent,
                prompt: prompt,
                participantEmail: participantEmail,
                documentHint: documentHint,
                participantId: selectedParticipantId,
                courseId: courseId,
                role: role,
                initiatedBy: email
            )
            lastRunMessage = selectedAgent.usesPlatformOrchestrator
                ? "Workflow started — check Approvals and Monitor."
                : "Run completed — see Monitoring for audit events."
            if selectedAgent.usesPlatformOrchestrator {
                promptText = ""
            }
        } catch {
            lastRunMessage = error.localizedDescription
        }
    }
}

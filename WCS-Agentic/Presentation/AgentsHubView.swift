//
//  AgentsHubView.swift
//  WCS-Agentic
//

import SwiftData
import SwiftUI

struct AgentsHubView: View {
    @EnvironmentObject private var session: SessionManager
    @Environment(\.modelContext) private var modelContext

    @State private var selectedAgent: AgentKind = .onboarding
    @State private var promptText = ""
    @State private var isRunning = false
    @State private var lastRunMessage: String?
    @State private var orchestrator: AgentOrchestrator?

    @Query(sort: \AgentRunRecord.createdAt, order: .reverse) private var runs: [AgentRunRecord]

    var body: some View {
        List {
            Section {
                AgenticHeroHeader(
                    title: "Agent Console",
                    subtitle: "Supervised workflows with explicit gates—onboarding, support, certificates, and campaigns. Automation stops before irreversible actions."
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
                Section {
                    Picker("Agent", selection: $selectedAgent) {
                        ForEach(AgentKind.allCases, id: \.self) { kind in
                            Label(kind.rawValue, systemImage: kind.systemImage).tag(kind)
                        }
                    }
                    .accessibilityIdentifier("agents.picker")

                    Text(selectedAgent.description)
                        .font(.footnote)
                        .foregroundStyle(.secondary)

                    TextField("Workflow prompt…", text: $promptText, axis: .vertical)
                        .lineLimit(3 ... 8)
                        .accessibilityIdentifier("agents.promptField")

                    Button {
                        Task { await runAgent() }
                    } label: {
                        Label(isRunning ? "Running…" : "Run supervised agent", systemImage: "play.circle.fill")
                    }
                    .disabled(isRunning || promptText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .accessibilityIdentifier("agents.runButton")

                    if let lastRunMessage {
                        Text(lastRunMessage)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Text("Interact")
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
                                        .lineLimit(4)
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
                runs: AgentRunRepository(modelContext: modelContext)
            )
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
        do {
            _ = try await orchestrator.run(agent: selectedAgent, prompt: promptText, initiatedBy: email)
            lastRunMessage = "Run completed — see Monitoring for audit events."
            promptText = ""
        } catch {
            lastRunMessage = error.localizedDescription
        }
    }
}

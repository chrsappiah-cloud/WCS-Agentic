//
//  ApprovalsQueueView.swift
//  WCS-Agentic
//

import SwiftUI

struct ApprovalsQueueView: View {
    @EnvironmentObject private var session: SessionManager
    @EnvironmentObject private var workflows: WorkflowCoordinator

    var body: some View {
        List {
            Section {
                AgenticHeroHeader(
                    title: "Approval queue",
                    subtitle: "Human gates for onboarding ID review, certificate dual-control, and policy-gated actions."
                )
                .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 8, trailing: 16))
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }

            if !session.isSignedIn {
                accessGate(title: "Sign in required", message: "Open Account to sign in before reviewing approvals.")
            } else if !session.canRunAgents {
                accessGate(title: "Operator access required", message: "Pro subscription and Operator/Admin role required.")
            } else {
                Section {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Orchestrator").font(.headline)
                            HealthStatusPill(text: workflows.orchestratorHealth)
                        }
                        Spacer()
                        if workflows.killSwitchActive {
                            Text("KILL SWITCH")
                                .font(.caption2.weight(.bold))
                                .foregroundStyle(.red)
                        }
                    }
                    Button("Refresh queue") {
                        Task { await workflows.refreshApprovals() }
                    }
                    .accessibilityIdentifier("approvals.refresh")
                }

                Section {
                    if workflows.pendingApprovals.isEmpty {
                        Text("No pending approvals.")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(workflows.pendingApprovals) { item in
                            approvalCard(item)
                        }
                    }
                } header: {
                    Text("Pending (\(workflows.pendingApprovals.count))")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .textCase(nil)
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(AgenticTheme.pageBackground.ignoresSafeArea())
        .navigationTitle("Approvals")
        .navigationBarTitleDisplayMode(.large)
        .task {
            await workflows.refreshPlatformStatus()
            await workflows.refreshApprovals()
        }
    }

    private func approvalCard(_ item: ApprovalItemDTO) -> some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text(item.payload?.type ?? "approval")
                        .font(.headline)
                    Spacer()
                    Text(item.status.uppercased())
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(AgenticTheme.bronze)
                }
                if let email = item.payload?.email {
                    Label(email, systemImage: "envelope")
                        .font(.subheadline)
                }
                if let message = item.payload?.message {
                    Text(message)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                Text("Session \(item.sessionId.prefix(8))…")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)

                HStack(spacing: 12) {
                    Button("Approve") {
                        Task {
                            await workflows.approve(item, approvedBy: session.currentUser?.email ?? "operator")
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(AgenticTheme.emerald)
                    .accessibilityIdentifier("approvals.approve.\(item.id)")

                    Button("Deny", role: .destructive) {
                        Task {
                            await workflows.deny(item, reason: "Denied from iOS approval queue")
                        }
                    }
                    .accessibilityIdentifier("approvals.deny.\(item.id)")
                }
            }
        }
        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
    }

    private func accessGate(title: String, message: String) -> some View {
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
}

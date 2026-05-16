//
//  MonitoringDashboardView.swift
//  WCS-Agentic
//

import SwiftData
import SwiftUI

struct MonitoringDashboardView: View {
    @ObservedObject var programsVM: ProgramsViewModel
    @EnvironmentObject private var workflows: WorkflowCoordinator
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \MonitoringEventRecord.createdAt, order: .reverse) private var events: [MonitoringEventRecord]

    var body: some View {
        List {
            Section {
                AgenticHeroHeader(
                    title: "Monitoring",
                    subtitle: "Unified signals from agents, API health, subscriptions, and access control—designed for operator triage."
                )
                .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 8, trailing: 16))
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }

            Section {
                GlassCard {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Vapor API").font(.headline)
                                HealthStatusPill(text: programsVM.lastHealth)
                                    .accessibilityIdentifier("monitor.apiHealth")
                            }
                            Spacer()
                            Button("Refresh") {
                                Task { await programsVM.refreshHealth() }
                            }
                            .accessibilityIdentifier("monitor.refreshHealth")
                        }
                        Divider()
                        HStack {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Orchestrator").font(.headline)
                                HealthStatusPill(text: workflows.orchestratorHealth)
                                    .accessibilityIdentifier("monitor.orchestratorHealth")
                            }
                            Spacer()
                            if workflows.killSwitchActive {
                                Text("KILL")
                                    .font(.caption2.weight(.bold))
                                    .foregroundStyle(.red)
                            }
                        }
                        Button("Sync platform audit") {
                            Task {
                                await workflows.refreshPlatformStatus()
                                await workflows.refreshAudit()
                            }
                        }
                        .font(.footnote)
                    }
                }
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }

            if !workflows.auditEvents.isEmpty {
                Section {
                    ForEach(workflows.auditEvents.prefix(15)) { event in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(event.type)
                                .font(.caption.weight(.semibold))
                            Text("Session \(event.sessionId.prefix(8))… · \(event.at)")
                                .font(.caption2)
                                .foregroundStyle(.tertiary)
                        }
                        .padding(.vertical, 2)
                    }
                } header: {
                    Text("Platform audit (recent)")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .textCase(nil)
                }
            }

            Section {
                HStack(spacing: 12) {
                    metricTile(title: "Events", value: "\(events.count)", icon: "waveform.path.ecg")
                    metricTile(
                        title: "Critical",
                        value: "\(events.filter { $0.severity == .critical }.count)",
                        icon: "bolt.trianglebadge.exclamationmark"
                    )
                    metricTile(
                        title: "Warnings",
                        value: "\(events.filter { $0.severity == .warning }.count)",
                        icon: "exclamationmark.triangle"
                    )
                }
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }

            Section {
                if events.isEmpty {
                    Text("No monitoring events yet. Run an agent or refresh API health.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(events.prefix(50), id: \.id) { event in
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: event.severity.systemImage)
                                .foregroundStyle(severityColor(event.severity))
                                .accessibilityHidden(true)
                            VStack(alignment: .leading, spacing: 4) {
                                Text(event.source)
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(.secondary)
                                Text(event.message)
                                    .font(.subheadline)
                                Text(event.createdAt.formatted(date: .abbreviated, time: .shortened))
                                    .font(.caption2)
                                    .foregroundStyle(.tertiary)
                            }
                        }
                        .padding(.vertical, 4)
                        .accessibilityElement(children: .combine)
                    }
                }
            } header: {
                Text("Event stream")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .textCase(nil)
            }
        }
        .scrollContentBackground(.hidden)
        .background(AgenticTheme.pageBackground.ignoresSafeArea())
        .navigationTitle("Monitoring")
        .navigationBarTitleDisplayMode(.large)
        .task {
            await programsVM.refreshHealth()
            await workflows.refreshPlatformStatus()
            await workflows.refreshAudit()
            try? MonitoringRepository(modelContext: modelContext).log(
                source: "Monitoring",
                message: "Dashboard opened — API health: \(programsVM.lastHealth)",
                severity: .info
            )
        }
    }

    private func metricTile(title: String, value: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Image(systemName: icon)
                .foregroundStyle(AgenticTheme.emerald)
            Text(value).font(.title2.weight(.semibold))
            Text(title).font(.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(.ultraThinMaterial)
        )
    }

    private func severityColor(_ severity: MonitoringSeverity) -> Color {
        switch severity {
        case .info: AgenticTheme.emerald
        case .warning: .orange
        case .critical: .red
        }
    }
}

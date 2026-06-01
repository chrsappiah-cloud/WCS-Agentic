//
//  FinanceAgentConsoleView.swift
//  WCS-Agentic
//

import SwiftUI

struct FinanceAgentConsoleView: View {
    let api: APIServing
    @StateObject private var workspace = FinanceAgentWorkspace()
    @State private var selectedArea: FinanceConsoleArea = .overview

    var body: some View {
        List {
            Section {
                AgenticHeroHeader(
                    title: "Finance AI Console",
                    subtitle: "Supervised accounting, governance, compliance, grants, reporting, and audit controls for World Class Scholars Australia."
                )
                .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 8, trailing: 16))
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }

            Section {
                if workspace.isSyncing {
                    ProgressView("Contacting backend…")
                        .accessibilityIdentifier("finance.backendProgress")
                }
                if let message = workspace.lastBackendMessage {
                    Label(message, systemImage: "server.rack")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .accessibilityIdentifier("finance.backendMessage")
                }
                Picker("Workspace", selection: $selectedArea) {
                    ForEach(FinanceConsoleArea.allCases) { area in
                        Label(area.title, systemImage: area.systemImage).tag(area)
                    }
                }
                .pickerStyle(.menu)
                .accessibilityIdentifier("finance.areaPicker")
            }

            switch selectedArea {
            case .overview:
                overview
            case .inbox:
                inbox
            case .reports:
                reports
            case .compliance:
                compliance
            case .governance:
                governance
            case .grants:
                grants
            case .audit:
                audit
            case .prompts:
                prompts
            }
        }
        .scrollContentBackground(.hidden)
        .background(AgenticTheme.pageBackground.ignoresSafeArea())
        .navigationTitle(selectedArea.title)
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button {
                    Task { await workspace.sync(api: api) }
                } label: {
                    Label("Sync", systemImage: "arrow.triangle.2.circlepath")
                }
                .accessibilityIdentifier("finance.syncButton")

                Button {
                    Task { await workspace.generateReport(api: api, period: "June 2026") }
                    selectedArea = .reports
                } label: {
                    Label("Generate report", systemImage: "doc.badge.plus")
                }
                .accessibilityIdentifier("finance.generateReportButton")
            }
        }
        .task {
            await workspace.sync(api: api)
        }
    }

    private var overview: some View {
        Group {
            Section {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 145), spacing: 12)], spacing: 12) {
                    metric("Inbox", "\(workspace.inboxRecords.count)", "tray.full", AgenticTheme.bronze)
                        .accessibilityIdentifier("finance.metric.inbox")
                    metric("Approval gates", "\(workspace.approvalRequiredCount)", "checkmark.shield", AgenticTheme.emerald)
                        .accessibilityIdentifier("finance.metric.approvals")
                    metric("Compliance", workspace.complianceRisk, "exclamationmark.triangle", .orange)
                        .accessibilityIdentifier("finance.metric.compliance")
                    metric("Posted value", Money(amount: workspace.postedTotal, currency: "AUD").display, "dollarsign.circle", .blue)
                        .accessibilityIdentifier("finance.metric.posted")
                }
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            } header: {
                sectionHeader("Operating state")
            }

            Section {
                ForEach(workspace.policyPacks) { pack in
                    GlassCard {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Label(pack.title, systemImage: "doc.badge.gearshape")
                                    .font(.headline)
                                Spacer()
                                Text(pack.status)
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(AgenticTheme.emerald)
                            }
                            Text("Reviewer: \(pack.reviewer)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            FlowText(items: pack.controls)
                        }
                    }
                    .cardRow()
                }
            } header: {
                sectionHeader("Configurable policy packs")
            }
        }
    }

    private var inbox: some View {
        Section {
            ForEach(workspace.inboxRecords) { record in
                GlassCard {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(record.description)
                                    .font(.headline)
                                Text("\(record.counterparty) • \(record.documentType)")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer(minLength: 10)
                            statusBadge(record.status.rawValue, color: record.status == .escalated ? .orange : AgenticTheme.emerald)
                        }

                        HStack {
                            Label(record.amount.display, systemImage: "dollarsign.circle")
                            Spacer()
                            Label("\(Int(record.confidence * 100))%", systemImage: "gauge.with.dots.needle.67percent")
                        }
                        .font(.footnote.weight(.medium))
                        .foregroundStyle(.secondary)

                        Text("\(record.accountCode) • \(record.taxCode)")
                            .font(.footnote.monospaced())
                            .foregroundStyle(.secondary)

                        Text(record.rationale)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)

                        HStack(spacing: 10) {
                            Button {
                                Task { await workspace.approve(record, api: api) }
                            } label: {
                                Label("Approve", systemImage: "checkmark.circle.fill")
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(AgenticTheme.emerald)
                            .accessibilityIdentifier("finance.approve.\(record.id.uuidString)")

                            Button {
                                Task { await workspace.escalate(record, api: api) }
                            } label: {
                                Label("Escalate", systemImage: "arrow.up.message")
                            }
                            .buttonStyle(.bordered)
                            .accessibilityIdentifier("finance.escalate.\(record.id.uuidString)")

                            if record.status == .approved {
                                Button {
                                    Task { await workspace.post(record, api: api) }
                                } label: {
                                    Label("Post", systemImage: "paperplane.fill")
                                }
                                .buttonStyle(.bordered)
                                .accessibilityIdentifier("finance.post.\(record.id.uuidString)")
                            }
                        }
                        .font(.footnote.weight(.semibold))
                    }
                }
                .cardRow()
            }
        } header: {
            sectionHeader("Ledger suggestions and approval gates")
        }
    }

    private var reports: some View {
        Group {
            ForEach(workspace.reports) { report in
                Section {
                    GlassCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text(report.title)
                                .font(.headline)
                            Text(report.period)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            ForEach(report.sections) { section in
                                VStack(alignment: .leading, spacing: 5) {
                                    Text(section.heading)
                                        .font(.subheadline.weight(.semibold))
                                    Text(section.body)
                                        .font(.footnote)
                                        .foregroundStyle(.secondary)
                                    FlowText(items: section.evidenceRefs)
                                }
                            }
                        }
                    }
                    .cardRow()

                    GlassCard {
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Decisions required", systemImage: "hand.raised")
                                .font(.headline)
                            ForEach(report.decisionsRequired, id: \.self) { decision in
                                Label(decision, systemImage: "circle")
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .cardRow()
                } header: {
                    sectionHeader("Board-ready reporting")
                }
            }
        }
    }

    private var compliance: some View {
        Section {
            ForEach(workspace.complianceTasks) { task in
                GlassCard {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(task.obligation)
                                    .font(.headline)
                                Text("\(task.regime) • \(task.jurisdiction) • \(task.owner)")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            statusBadge(task.severity.rawValue, color: color(for: task.severity))
                        }
                        Text("Due \(task.dueDate.formatted(date: .abbreviated, time: .omitted))")
                            .font(.footnote.weight(.semibold))
                        Text(task.recommendedAction)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                        FlowText(items: task.evidenceRequired)
                        Button {
                            Task { await workspace.complete(task, api: api) }
                        } label: {
                            Label(task.status == .completed ? "Completed" : "Mark complete", systemImage: "checkmark.seal")
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(task.status == .completed ? .gray : AgenticTheme.emerald)
                        .disabled(task.status == .completed)
                        .accessibilityIdentifier("finance.completeTask.\(task.id.uuidString)")
                    }
                }
                .cardRow()
            }
        } header: {
            sectionHeader("Obligations register")
        }
    }

    private var governance: some View {
        Section {
            ForEach(workspace.governanceEvents) { event in
                GlassCard {
                    VStack(alignment: .leading, spacing: 10) {
                        Label(event.eventType, systemImage: "building.columns")
                            .font(.headline)
                        if let date = event.meetingDate {
                            Text(date.formatted(date: .abbreviated, time: .omitted))
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        Text(event.resolutionText)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                        FlowText(items: event.approvers)
                        Text(event.explainabilityNote)
                            .font(.caption)
                            .foregroundStyle(AgenticTheme.emerald)
                        Button {
                            Task { await workspace.addBoardApprovalNote(for: event, api: api) }
                        } label: {
                            Label("Capture approval note", systemImage: "square.and.pencil")
                        }
                        .buttonStyle(.bordered)
                        .accessibilityIdentifier("finance.captureGovernanceNote.\(event.id.uuidString)")
                    }
                }
                .cardRow()
            }
        } header: {
            sectionHeader("Governance controls")
        }
    }

    private var grants: some View {
        Section {
            ForEach(workspace.grants) { grant in
                GlassCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(grant.grantName)
                            .font(.headline)
                        Text("\(grant.fundingBody) • \(grant.startDate.formatted(date: .abbreviated, time: .omitted)) to \(grant.endDate.formatted(date: .abbreviated, time: .omitted))")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        FlowText(items: grant.eligibleCostRules)
                        ForEach(grant.milestones) { milestone in
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Label(milestone.title, systemImage: "flag.checkered")
                                        .font(.subheadline.weight(.semibold))
                                    Spacer()
                                    if let tranche = milestone.trancheAmount {
                                        Text(tranche.display)
                                            .font(.caption.weight(.bold))
                                            .foregroundStyle(AgenticTheme.emerald)
                                    }
                                }
                                Text("Due \(milestone.dueDate.formatted(date: .abbreviated, time: .omitted))")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                FlowText(items: milestone.requiredEvidence)
                            }
                            .padding(12)
                            .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 8))
                        }
                    }
                }
                .cardRow()
            }
        } header: {
            sectionHeader("Grants and investment management")
        }
    }

    private var audit: some View {
        Section {
            ForEach(workspace.auditTrail) { event in
                GlassCard {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Label(event.action, systemImage: "clock.badge.checkmark")
                                .font(.headline)
                            Spacer()
                            Text(event.timestamp.formatted(date: .omitted, time: .shortened))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Text(event.object)
                            .font(.subheadline)
                        Text(event.actor)
                            .font(.caption.monospaced())
                            .foregroundStyle(.secondary)
                        Text(event.rationale)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
                .cardRow()
            }
        } header: {
            sectionHeader("Decision log and explainability")
        }
    }

    private var prompts: some View {
        Section {
            ForEach(FinanceAgentPromptLibrary.templates) { prompt in
                GlassCard {
                    VStack(alignment: .leading, spacing: 10) {
                        Label(prompt.id.rawValue, systemImage: "text.badge.checkmark")
                            .font(.headline)
                        promptBlock("System", prompt.system)
                        promptBlock("Developer", prompt.developer)
                        promptBlock("User", prompt.user)
                        promptBlock("Output", prompt.outputContract)
                    }
                }
                .cardRow()
            }
        } header: {
            sectionHeader("Structured prompt library")
        }
    }

    private func metric(_ title: String, _ value: String, _ icon: String, _ color: Color) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icon)
                .font(.title3.weight(.semibold))
                .foregroundStyle(color)
            Text(value)
                .font(.headline)
                .lineLimit(2)
                .minimumScaleFactor(0.72)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 112, alignment: .leading)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(Color.primary.opacity(0.06), lineWidth: 1)
        )
    }

    private func statusBadge(_ text: String, color: Color) -> some View {
        Text(text.uppercased())
            .font(.caption2.weight(.bold))
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(color.opacity(0.14), in: Capsule())
            .foregroundStyle(color)
            .lineLimit(1)
            .minimumScaleFactor(0.75)
    }

    private func promptBlock(_ title: String, _ body: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption.weight(.bold))
                .foregroundStyle(AgenticTheme.emerald)
            Text(body)
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func sectionHeader(_ text: String) -> some View {
        Text(text)
            .font(.footnote.weight(.semibold))
            .foregroundStyle(.secondary)
            .textCase(nil)
    }

    private func color(for severity: Severity) -> Color {
        switch severity {
        case .low: return .blue
        case .medium: return AgenticTheme.bronze
        case .high: return .orange
        case .critical: return .red
        }
    }
}

private enum FinanceConsoleArea: String, CaseIterable, Identifiable {
    case overview, inbox, reports, compliance, governance, grants, audit, prompts

    var id: String { rawValue }

    var title: String {
        switch self {
        case .overview: return "Overview"
        case .inbox: return "Inbox"
        case .reports: return "Reports"
        case .compliance: return "Compliance"
        case .governance: return "Governance"
        case .grants: return "Grants"
        case .audit: return "Audit"
        case .prompts: return "Prompts"
        }
    }

    var systemImage: String {
        switch self {
        case .overview: return "rectangle.grid.2x2"
        case .inbox: return "tray.full"
        case .reports: return "chart.bar.doc.horizontal"
        case .compliance: return "checklist"
        case .governance: return "building.columns"
        case .grants: return "flag.checkered"
        case .audit: return "clock.badge.checkmark"
        case .prompts: return "text.badge.checkmark"
        }
    }
}

private struct FlowText: View {
    let items: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(items, id: \.self) { item in
                Label(item, systemImage: "checkmark.circle")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

private extension View {
    func cardRow() -> some View {
        listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
    }
}

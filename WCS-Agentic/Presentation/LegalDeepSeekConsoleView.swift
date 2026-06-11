//
//  LegalDeepSeekConsoleView.swift
//  WCS-Agentic
//

import SwiftUI

struct LegalDeepSeekConsoleView: View {
    @StateObject private var workspace = LegalDeepSeekWorkspace()
    @State private var selectedArea: LegalConsoleArea = .overview

    var body: some View {
        List {
            Section {
                AgenticHeroHeader(
                    title: "Legal DeepSeek Sub-Agent",
                    subtitle: "Offline-first legal reasoning, prompt governance, evidence-bounded drafting, and lawyer approval gates for contract, litigation, compliance, writing, intake, and marketing workflows."
                )
                .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 8, trailing: 16))
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }

            Section {
                Picker("Console", selection: $selectedArea) {
                    ForEach(LegalConsoleArea.allCases) { area in
                        Label(area.title, systemImage: area.systemImage).tag(area)
                    }
                }
                .pickerStyle(.menu)
                .accessibilityIdentifier("legal.areaPicker")

                Picker("Runtime", selection: $workspace.runtimeMode) {
                    ForEach(LegalDeepSeekRuntimeMode.allCases) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .accessibilityIdentifier("legal.runtimePicker")

                Text(workspace.runtimeRecommendation)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            switch selectedArea {
            case .overview:
                overview
            case .matters:
                matters
            case .promptLab:
                promptLab
            case .reviews:
                reviews
            case .safeguards:
                safeguards
            case .audit:
                audit
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
                    workspace.blockCloudForConfidentialMatter()
                } label: {
                    Label("Local", systemImage: "lock.laptopcomputer")
                }
                .accessibilityIdentifier("legal.forceLocalButton")

                Button {
                    _ = workspace.runSelectedReview()
                    selectedArea = .reviews
                } label: {
                    Label("Run", systemImage: "play.circle.fill")
                }
                .accessibilityIdentifier("legal.runReviewButton")
            }
        }
    }

    private var overview: some View {
        Group {
            Section {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 145), spacing: 12)], spacing: 12) {
                    metric("Matters", "\(workspace.matters.count)", "folder.badge.gearshape", AgenticTheme.emerald)
                        .accessibilityIdentifier("legal.metric.matters")
                    metric("Review gates", "\(workspace.lawyerReviewCount)", "person.badge.shield.checkmark", AgenticTheme.bronze)
                        .accessibilityIdentifier("legal.metric.reviewGates")
                    metric("High risks", "\(workspace.highRiskCount)", "exclamationmark.triangle", .orange)
                        .accessibilityIdentifier("legal.metric.highRisks")
                    metric("Prompt packs", "\(LegalDeepSeekPromptLibrary.templates.count)", "text.badge.checkmark", .blue)
                        .accessibilityIdentifier("legal.metric.prompts")
                }
                .legalCardRow()
            } header: {
                sectionHeader("Operating state")
            }

            Section {
                ForEach(LegalDeepSeekPromptLibrary.playbookSummary, id: \.self) { item in
                    GlassCard {
                        Label(item, systemImage: "checkmark.seal")
                            .font(.footnote)
                            .foregroundStyle(.primary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .legalCardRow()
                }
            } header: {
                sectionHeader("DeepSeek legal playbook")
            }
        }
    }

    private var matters: some View {
        Section {
            ForEach(workspace.matters) { matter in
                GlassCard {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 4) {
                                Label(matter.name, systemImage: matter.practiceArea.systemImage)
                                    .font(.headline)
                                    .foregroundStyle(.primary)
                                Text("\(matter.clientReference) - \(matter.jurisdiction) - \(matter.confidentialityLevel)")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer(minLength: 8)
                            statusBadge(matter.reviewStatus.rawValue, color: color(for: matter.reviewStatus))
                        }

                        Text(matter.objective)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)

                        LegalFlowText(items: workspace.evidence(for: matter).map(\.fileName))

                        Button {
                            workspace.setPracticeArea(matter.practiceArea)
                            _ = workspace.runSelectedReview()
                            selectedArea = .reviews
                        } label: {
                            Label("Run legal draft", systemImage: "play.circle")
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(AgenticTheme.emerald)
                        .accessibilityIdentifier("legal.runMatter.\(matter.id.uuidString)")
                    }
                }
                .legalCardRow()
            }
        } header: {
            sectionHeader("Legal matters")
        }
    }

    private var promptLab: some View {
        Group {
            Section {
                Picker(
                    "Practice area",
                    selection: Binding(
                        get: { workspace.selectedPracticeArea },
                        set: { workspace.setPracticeArea($0) }
                    )
                ) {
                    ForEach(LegalDeepSeekPracticeArea.allCases) { area in
                        Label(area.rawValue, systemImage: area.systemImage).tag(area)
                    }
                }
                .accessibilityIdentifier("legal.practiceAreaPicker")

                Picker("Prompt template", selection: $workspace.selectedTemplateID) {
                    ForEach(workspace.templatesForSelectedArea) { template in
                        Text(template.title).tag(template.id)
                    }
                }
                .accessibilityIdentifier("legal.templatePicker")

                TextField("Additional context for this legal draft", text: $workspace.additionalContext, axis: .vertical)
                    .lineLimit(2 ... 6)
                    .accessibilityIdentifier("legal.additionalContext")

                Button {
                    _ = workspace.runSelectedReview()
                    selectedArea = .reviews
                } label: {
                    Label("Generate lawyer-review draft", systemImage: "doc.badge.plus")
                }
                .buttonStyle(.borderedProminent)
                .tint(AgenticTheme.emerald)
                .accessibilityIdentifier("legal.generateDraftButton")
            } header: {
                sectionHeader("Prompt builder")
            }

            Section {
                ForEach(workspace.templatesForSelectedArea) { template in
                    GlassCard {
                        VStack(alignment: .leading, spacing: 10) {
                            Label(template.title, systemImage: template.practiceArea.systemImage)
                                .font(.headline)
                                .foregroundStyle(.primary)
                            promptBlock("Purpose", template.purpose)
                            promptBlock("Prompt", template.userPrompt)
                            promptBlock("Output", template.outputContract)
                            LegalFlowText(items: template.riskControls)
                        }
                    }
                    .legalCardRow()
                }
            } header: {
                sectionHeader("Prompt templates")
            }
        }
    }

    private var reviews: some View {
        Section {
            if workspace.reviews.isEmpty {
                GlassCard {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("No legal drafts yet", systemImage: "tray")
                            .font(.headline)
                        Text("Run a matter or prompt template to create a DeepSeek-style legal draft with lawyer approval gates.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .legalCardRow()
            } else {
                ForEach(workspace.reviews) { review in
                    GlassCard {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(alignment: .top) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Label(review.promptTitle, systemImage: "doc.text.magnifyingglass")
                                        .font(.headline)
                                    Text("\(review.runtimeMode.rawValue) - \(review.modelName)")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer(minLength: 8)
                                statusBadge(review.status.rawValue, color: color(for: review.status))
                            }

                            Text(review.executiveSummary)
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)

                            ForEach(review.findings) { finding in
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack {
                                        Text(finding.title)
                                            .font(.subheadline.weight(.semibold))
                                        Spacer()
                                        statusBadge(finding.riskLevel.rawValue, color: color(for: finding.riskLevel))
                                    }
                                    Text(finding.summary)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    Text(finding.recommendedAction)
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(AgenticTheme.emerald)
                                    if finding.needsCitationVerification {
                                        Label("Citation/source verification required", systemImage: "books.vertical")
                                            .font(.caption)
                                            .foregroundStyle(.orange)
                                    }
                                }
                                .padding(12)
                                .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 8))
                            }

                            LegalFlowText(items: review.disclaimers)

                            Button {
                                workspace.approve(review)
                            } label: {
                                Label("Mark lawyer reviewed", systemImage: "checkmark.seal")
                            }
                            .buttonStyle(.bordered)
                            .disabled(review.status == .approved)
                            .accessibilityIdentifier("legal.approveReview.\(review.id.uuidString)")
                        }
                    }
                    .legalCardRow()
                }
            }
        } header: {
            sectionHeader("Draft reviews")
        }
    }

    private var safeguards: some View {
        Group {
            Section {
                GlassCard {
                    VStack(alignment: .leading, spacing: 10) {
                        Label("System guardrails", systemImage: "shield.lefthalf.filled")
                            .font(.headline)
                            .foregroundStyle(.primary)
                        Text(LegalDeepSeekPromptLibrary.systemGuardrails)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .legalCardRow()

                GlassCard {
                    VStack(alignment: .leading, spacing: 10) {
                        Label("Developer guardrails", systemImage: "list.bullet.clipboard")
                            .font(.headline)
                            .foregroundStyle(.primary)
                        Text(LegalDeepSeekPromptLibrary.developerGuardrails)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .legalCardRow()
            } header: {
                sectionHeader("Legal AI safety")
            }

            if let matter = workspace.matter() {
                Section {
                    let invocation = workspace.buildInvocation(for: matter)
                    GlassCard {
                        VStack(alignment: .leading, spacing: 12) {
                            promptBlock("System", invocation.system)
                            promptBlock("Developer", invocation.developer)
                            promptBlock("User", invocation.user)
                            promptBlock("Output", invocation.outputContract)
                        }
                    }
                    .legalCardRow()
                } header: {
                    sectionHeader("Current invocation")
                }
            }
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
                .legalCardRow()
            }
        } header: {
            sectionHeader("Legal audit trail")
        }
    }

    private func metric(_ title: String, _ value: String, _ icon: String, _ color: Color) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icon)
                .font(.title3.weight(.semibold))
                .foregroundStyle(color)
            Text(value)
                .font(.headline)
                .foregroundStyle(.primary)
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

    private func promptBlock(_ title: String, _ body: String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.caption.weight(.bold))
                .foregroundStyle(AgenticTheme.emerald)
            Text(body)
                .font(.caption)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func statusBadge(_ text: String, color: Color) -> some View {
        Text(text.uppercased())
            .font(.caption2.weight(.bold))
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(color.opacity(0.14), in: Capsule())
            .foregroundStyle(color)
            .lineLimit(1)
            .minimumScaleFactor(0.68)
    }

    private func sectionHeader(_ text: String) -> some View {
        Text(text)
            .font(.footnote.weight(.semibold))
            .foregroundStyle(.secondary)
            .textCase(nil)
    }

    private func color(for status: LegalDeepSeekReviewStatus) -> Color {
        switch status {
        case .draft: return .blue
        case .lawyerReviewRequired: return AgenticTheme.bronze
        case .approved: return AgenticTheme.emerald
        case .blocked: return .red
        }
    }

    private func color(for risk: LegalDeepSeekRiskLevel) -> Color {
        switch risk {
        case .low: return .blue
        case .medium: return AgenticTheme.bronze
        case .high: return .orange
        case .critical: return .red
        }
    }
}

private enum LegalConsoleArea: String, CaseIterable, Identifiable {
    case overview, matters, promptLab, reviews, safeguards, audit

    var id: String { rawValue }

    var title: String {
        switch self {
        case .overview: return "Overview"
        case .matters: return "Matters"
        case .promptLab: return "Prompt Lab"
        case .reviews: return "Reviews"
        case .safeguards: return "Safeguards"
        case .audit: return "Audit"
        }
    }

    var systemImage: String {
        switch self {
        case .overview: return "rectangle.grid.2x2"
        case .matters: return "folder.badge.gearshape"
        case .promptLab: return "text.badge.checkmark"
        case .reviews: return "doc.text.magnifyingglass"
        case .safeguards: return "shield.checkered"
        case .audit: return "clock.badge.checkmark"
        }
    }
}

private struct LegalFlowText: View {
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
    func legalCardRow() -> some View {
        listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
    }
}

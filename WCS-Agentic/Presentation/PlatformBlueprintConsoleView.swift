//
//  PlatformBlueprintConsoleView.swift
//  WCS-Agentic
//

import SwiftUI

struct PlatformBlueprintConsoleView: View {
    @StateObject private var workspace = PlatformBlueprintWorkspace()
    @State private var selectedArea: BlueprintConsoleArea

    init() {
        _selectedArea = State(
            initialValue: ProcessInfo.processInfo.arguments.contains("--start-blueprint-performance") ? .performance : .overview
        )
    }

    var body: some View {
        List {
            Section {
                AgenticHeroHeader(
                    title: "WCS Platform Blueprint",
                    subtitle: "Portfolio operating model, shared architecture, launch readiness, analytics, ethics controls, roadmap, and Codex prompt pack for the World Class Scholars app family."
                )
                .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 8, trailing: 16))
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }

            Section {
                Picker("Blueprint area", selection: $selectedArea) {
                    ForEach(BlueprintConsoleArea.allCases) { area in
                        Label(area.title, systemImage: area.systemImage).tag(area)
                    }
                }
                .pickerStyle(.menu)
                .accessibilityIdentifier("blueprint.areaPicker")

                Text(workspace.nextReleaseAction)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("blueprint.nextAction")
            }

            switch selectedArea {
            case .overview:
                overview
            case .performance:
                performance
            case .portfolio:
                portfolio
            case .operatingModel:
                operatingModel
            case .architecture:
                architecture
            case .release:
                release
            case .analytics:
                analytics
            case .ethics:
                ethics
            case .prompts:
                prompts
            case .roadmap:
                roadmap
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
                    workspace.completeNextGate()
                    selectedArea = .release
                } label: {
                    Label("Complete gate", systemImage: "checkmark.seal")
                }
                .accessibilityIdentifier("blueprint.completeNextGate")

                Button {
                    workspace.resetReleaseGates()
                    selectedArea = .release
                } label: {
                    Label("Reset", systemImage: "arrow.counterclockwise")
                }
                .accessibilityIdentifier("blueprint.resetGates")
            }
        }
    }

    private var overview: some View {
        Group {
            Section {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 145), spacing: 12)], spacing: 12) {
                    metric("Apps", "\(workspace.portfolioApps.count)", "square.grid.3x3", AgenticTheme.emerald)
                        .accessibilityIdentifier("blueprint.metric.apps")
                    metric("Medical apps", "\(workspace.medicalAppCount)", "cross.case", .red)
                        .accessibilityIdentifier("blueprint.metric.medical")
                    metric("Shared capabilities", "\(workspace.sharedCapabilityCount)", "shippingbox", AgenticTheme.bronze)
                        .accessibilityIdentifier("blueprint.metric.capabilities")
                    metric("Readiness", "\(workspace.launchReadinessPercent)%", "checkmark.shield", .blue)
                        .accessibilityIdentifier("blueprint.metric.readiness")
                    metric("Visible ratings", "\(workspace.totalVisibleRatings)", "star", AgenticTheme.bronze)
                        .accessibilityIdentifier("blueprint.metric.ratings")
                }
                .blueprintCardRow()
            } header: {
                sectionHeader("Portfolio state")
            }

            Section {
                GlassCard {
                    VStack(alignment: .leading, spacing: 10) {
                        Label("Shared platform thesis", systemImage: "rectangle.connected.to.line.below")
                            .font(.headline)
                            .foregroundStyle(AgenticTheme.ink)
                        Text("One reusable WCS platform should power multiple branded iOS app shells with shared identity, design, analytics, notifications, feature flags, agent workflows, backend APIs, admin tooling, support operations, and governance.")
                            .font(.footnote)
                            .foregroundStyle(AgenticTheme.ink.opacity(0.78))
                            .fixedSize(horizontal: false, vertical: true)
                        Text(workspace.blueprintCoverageSummary)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(AgenticTheme.emerald)
                            .fixedSize(horizontal: false, vertical: true)
                        FlowList(items: ["Identity and tenancy", "Design system and SwiftUI components", "Analytics and retention instrumentation", "Push and lifecycle messaging", "Agent workflows with audit trails", "Backend APIs and support console"])
                    }
                }
                .blueprintCardRow()
            } header: {
                sectionHeader("Implementation priority")
            }
        }
    }

    private var performance: some View {
        Group {
            Section {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 145), spacing: 12)], spacing: 12) {
                    metric("Live apps", "\(workspace.livePortfolioCount)", "app.badge", AgenticTheme.emerald)
                        .accessibilityIdentifier("blueprint.performance.liveApps")
                    metric("Zero-rating apps", "\(workspace.zeroRatingProfiles.count)", "star.slash", AgenticTheme.bronze)
                        .accessibilityIdentifier("blueprint.performance.zeroRatings")
                    metric("Paid apps", "\(workspace.paidPostLaunchProfiles.count)", "dollarsign.circle", .blue)
                        .accessibilityIdentifier("blueprint.performance.paidApps")
                    metric("Highest price", workspace.highestVisiblePriceProfile?.priceAUD ?? "-", "chart.line.uptrend.xyaxis", .purple)
                        .accessibilityIdentifier("blueprint.performance.highestPrice")
                }
                .blueprintCardRow()

                GlassCard {
                    VStack(alignment: .leading, spacing: 10) {
                        Label(workspace.postLaunchRiskSummary, systemImage: "exclamationmark.triangle")
                            .font(.headline)
                            .foregroundStyle(AgenticTheme.ink)
                        Text("All live products should feed a shared weekly scorecard so acquisition, activation, retention, reliability, support, and rating proof can be compared across the WCS portfolio.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                        FlowList(items: workspace.postLaunchScorecardSignals)
                    }
                }
                .blueprintCardRow()
            } header: {
                sectionHeader("Post-launch portfolio monitor")
            }

            Section {
                GlassCard {
                    VStack(alignment: .leading, spacing: 10) {
                        Label(workspace.postLaunchEngineStatusSummary, systemImage: "cpu")
                            .font(.headline)
                            .foregroundStyle(AgenticTheme.ink)
                            .fixedSize(horizontal: false, vertical: true)
                        Text("The monitoring layer turns the post-launch strategy into executable scorecards, rating safeguards, review triage, support routing, roadmap recommendations, and telemetry coverage checks.")
                            .font(.footnote)
                            .foregroundStyle(AgenticTheme.ink.opacity(0.78))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .blueprintCardRow()

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 145), spacing: 12)], spacing: 12) {
                    metric("New installs", "\(workspace.portfolioScorecard.totalNewInstalls)", "arrow.down.app", AgenticTheme.emerald)
                        .accessibilityIdentifier("blueprint.engine.newInstalls")
                    metric("Store conversion", percent(workspace.portfolioScorecard.averageStoreConversionRate), "storefront", .blue)
                        .accessibilityIdentifier("blueprint.engine.conversion")
                    metric("D30 retention", percent(workspace.portfolioScorecard.averageDay30Retention), "calendar.badge.clock", AgenticTheme.bronze)
                        .accessibilityIdentifier("blueprint.engine.retention")
                    metric("Crash-free users", percent(workspace.portfolioScorecard.averageCrashFreeUsersRate), "checkmark.shield", .green)
                        .accessibilityIdentifier("blueprint.engine.crashFreeUsers")
                }
                .blueprintCardRow()
            } header: {
                sectionHeader("Monitoring engine outputs")
            }

            Section {
                ForEach(workspace.installedMonitoringEngines) { engine in
                    GlassCard {
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: "sparkles.rectangle.stack")
                                .font(.title3.weight(.semibold))
                                .foregroundStyle(AgenticTheme.bronze)
                            VStack(alignment: .leading, spacing: 6) {
                                HStack(alignment: .firstTextBaseline) {
                                    Text(engine.name)
                                        .font(.headline)
                                        .foregroundStyle(AgenticTheme.ink)
                                    Spacer()
                                    statusBadge(engine.status, color: AgenticTheme.emerald)
                                }
                                Text(engine.purpose)
                                    .font(.footnote)
                                    .foregroundStyle(AgenticTheme.ink.opacity(0.76))
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                    .blueprintCardRow()
                    .accessibilityIdentifier("blueprint.engine.installed.\(engine.name)")
                }
            } header: {
                sectionHeader("Installed monitoring engines")
            }

            Section {
                ForEach(workspace.ratingPromptDecisions) { decision in
                    GlassCard {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(alignment: .top) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(decision.appName)
                                        .font(.headline)
                                        .foregroundStyle(AgenticTheme.ink)
                                    Text(decision.reason)
                                        .font(.footnote)
                                        .foregroundStyle(AgenticTheme.ink.opacity(0.76))
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                Spacer()
                                statusBadge(decision.shouldPrompt ? "Prompt" : "Suppress", color: decision.shouldPrompt ? AgenticTheme.emerald : AgenticTheme.bronze)
                            }
                            Text(decision.nextAction)
                                .font(.caption)
                                .foregroundStyle(AgenticTheme.ink.opacity(0.78))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    .blueprintCardRow()
                    .accessibilityIdentifier("blueprint.engine.rating.\(decision.appName)")
                }

                ForEach(workspace.roadmapRecommendations.prefix(4)) { recommendation in
                    GlassCard {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(alignment: .firstTextBaseline) {
                                Text(recommendation.appName)
                                    .font(.headline)
                                    .foregroundStyle(AgenticTheme.ink)
                                Spacer()
                                statusBadge(recommendation.decision.rawValue, color: AgenticTheme.bronze)
                            }
                            Text(recommendation.rationale)
                                .font(.footnote)
                                .foregroundStyle(AgenticTheme.ink.opacity(0.76))
                                .fixedSize(horizontal: false, vertical: true)
                            FlowList(items: recommendation.actions)
                        }
                    }
                    .blueprintCardRow()
                    .accessibilityIdentifier("blueprint.engine.roadmap.\(recommendation.appName)")
                }
            } header: {
                sectionHeader("Rating and roadmap decisions")
            }

            Section {
                GlassCard {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Review triage")
                            .font(.headline)
                            .foregroundStyle(AgenticTheme.ink)
                        Text("\(workspace.reviewTriageDemo.appName) routes to \(workspace.reviewTriageDemo.route).")
                            .font(.footnote)
                            .foregroundStyle(AgenticTheme.ink.opacity(0.78))
                            .fixedSize(horizontal: false, vertical: true)
                        statusBadge(workspace.reviewTriageDemo.category.rawValue, color: AgenticTheme.bronze)
                        Text(workspace.reviewTriageDemo.roadmapSignal)
                            .font(.caption)
                            .foregroundStyle(AgenticTheme.ink.opacity(0.72))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .blueprintCardRow()

                if let supportTriageDemo = workspace.supportTriageDemo {
                    GlassCard {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Support SLA triage")
                                .font(.headline)
                                .foregroundStyle(AgenticTheme.ink)
                            Text("\(supportTriageDemo.appName): \(supportTriageDemo.targetResponse)")
                                .font(.footnote.weight(.semibold))
                                .foregroundStyle(AgenticTheme.ink)
                                .fixedSize(horizontal: false, vertical: true)
                            Text(supportTriageDemo.escalation)
                                .font(.caption)
                                .foregroundStyle(AgenticTheme.ink.opacity(0.72))
                                .fixedSize(horizontal: false, vertical: true)
                            FlowList(items: supportTriageDemo.tags)
                        }
                    }
                    .blueprintCardRow()
                }
            } header: {
                sectionHeader("Review and support triage")
            }

            Section {
                ForEach(workspace.postLaunchProfiles) { profile in
                    GlassCard {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(alignment: .top) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(profile.appName)
                                        .font(.headline)
                                        .foregroundStyle(AgenticTheme.ink)
                                    Text("\(profile.category.rawValue) · \(profile.publicStatus)")
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(AgenticTheme.emerald)
                                }
                                Spacer()
                                VStack(alignment: .trailing, spacing: 4) {
                                    Text(profile.priceAUD)
                                        .font(.caption.weight(.bold))
                                        .foregroundStyle(AgenticTheme.bronze)
                                    statusBadge("\(profile.visibleRatingCount) ratings", color: profile.needsRatingsGeneration ? AgenticTheme.bronze : AgenticTheme.emerald)
                                }
                            }

                            Text(profile.productMandate)
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)

                            VStack(alignment: .leading, spacing: 6) {
                                Label("North-star goal", systemImage: "scope")
                                    .font(.subheadline.weight(.semibold))
                                Text(profile.northStarGoal)
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }

                            ForEach(profile.kpiGroups.prefix(3)) { kpi in
                                VStack(alignment: .leading, spacing: 5) {
                                    Text(kpi.domain)
                                        .font(.caption.weight(.bold))
                                        .foregroundStyle(AgenticTheme.emerald)
                                    FlowList(items: kpi.measures)
                                }
                            }

                            Divider()

                            VStack(alignment: .leading, spacing: 6) {
                                Text("App Store actions")
                                    .font(.caption.weight(.bold))
                                    .foregroundStyle(AgenticTheme.bronze)
                                FlowList(items: profile.appStoreActions)
                            }

                            VStack(alignment: .leading, spacing: 6) {
                                Text("Roadmap waves")
                                    .font(.caption.weight(.bold))
                                    .foregroundStyle(AgenticTheme.emerald)
                                FlowList(items: profile.roadmapWaves)
                            }
                        }
                    }
                    .blueprintCardRow()
                    .accessibilityIdentifier("blueprint.performance.profile.\(profile.appName)")
                }
            } header: {
                sectionHeader("Live app performance profiles")
            }

            Section {
                ForEach(workspace.postLaunchEventTaxonomy) { group in
                    GlassCard {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(group.group)
                                .font(.headline)
                                .foregroundStyle(AgenticTheme.ink)
                            Text(group.purpose)
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                            FlowList(items: group.exampleEvents)
                        }
                    }
                    .blueprintCardRow()
                }
            } header: {
                sectionHeader("Instrumentation taxonomy")
            }

            Section {
                ForEach(workspace.supportServiceLevels) { serviceLevel in
                    GlassCard {
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: "timer")
                                .foregroundStyle(AgenticTheme.bronze)
                            VStack(alignment: .leading, spacing: 4) {
                                Text(serviceLevel.issueType)
                                    .font(.headline)
                                    .foregroundStyle(AgenticTheme.ink)
                                Text(serviceLevel.targetResponse)
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .blueprintCardRow()
                }
            } header: {
                sectionHeader("Support service levels")
            }

            Section {
                GlassCard {
                    VStack(alignment: .leading, spacing: 8) {
                        Label(workspace.executionPackSummary, systemImage: "doc.text.magnifyingglass")
                            .font(.headline)
                            .foregroundStyle(AgenticTheme.ink)
                            .fixedSize(horizontal: false, vertical: true)
                        Text("The long-form post-launch report can be expanded with screenshots, KPI templates, release logs, review excerpts, support taxonomies, cohort charts, and SOP appendices.")
                            .font(.footnote)
                            .foregroundStyle(AgenticTheme.ink.opacity(0.78))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .blueprintCardRow()

                ForEach(workspace.portfolioReviewLoops) { loop in
                    GlassCard {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(alignment: .firstTextBaseline) {
                                Text(loop.cadence)
                                    .font(.headline)
                                    .foregroundStyle(AgenticTheme.ink)
                                Spacer()
                                Text(loop.focus)
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(AgenticTheme.emerald)
                                    .multilineTextAlignment(.trailing)
                            }
                            FlowList(items: loop.decisions)
                        }
                    }
                    .blueprintCardRow()
                }
            } header: {
                sectionHeader("Portfolio review loops")
            }

            Section {
                ForEach(workspace.telemetryLayers) { layer in
                    GlassCard {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(layer.layer)
                                .font(.headline)
                                .foregroundStyle(AgenticTheme.ink)
                            Text(layer.managementUse)
                                .font(.footnote)
                                .foregroundStyle(AgenticTheme.ink.opacity(0.78))
                                .fixedSize(horizontal: false, vertical: true)
                            FlowList(items: layer.captures)
                        }
                    }
                    .blueprintCardRow()
                }
            } header: {
                sectionHeader("Telemetry layers")
            }

            Section {
                ForEach(workspace.reviewOperations) { operation in
                    GlassCard {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(operation.workflow)
                                .font(.headline)
                                .foregroundStyle(AgenticTheme.ink)
                            FlowList(items: operation.practices)
                        }
                    }
                    .blueprintCardRow()
                }

                GlassCard {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Support taxonomy")
                            .font(.headline)
                            .foregroundStyle(AgenticTheme.ink)
                        ForEach(workspace.supportTaxonomyFields) { field in
                            HStack(alignment: .top, spacing: 8) {
                                Text(field.field)
                                    .font(.caption.weight(.bold))
                                    .foregroundStyle(AgenticTheme.bronze)
                                    .frame(width: 96, alignment: .leading)
                                Text(field.purpose)
                                    .font(.caption)
                                    .foregroundStyle(AgenticTheme.ink.opacity(0.76))
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                }
                .blueprintCardRow()
            } header: {
                sectionHeader("Ratings and support operations")
            }

            Section {
                ForEach(workspace.riskEthicsFocusAreas) { area in
                    GlassCard {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(area.productGroup)
                                .font(.headline)
                                .foregroundStyle(AgenticTheme.ink)
                            FlowList(items: area.controls)
                        }
                    }
                    .blueprintCardRow()
                }
            } header: {
                sectionHeader("Risk and ethics focus")
            }

            Section {
                ForEach(workspace.reportAssemblyPlan) { item in
                    GlassCard {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(item.section)
                                .font(.headline)
                                .foregroundStyle(AgenticTheme.ink)
                            FlowList(items: item.contents)
                        }
                    }
                    .blueprintCardRow()
                }

                ForEach(workspace.appSupplements) { supplement in
                    GlassCard {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(supplement.appName)
                                .font(.headline)
                                .foregroundStyle(AgenticTheme.ink)
                            FlowList(items: supplement.supplementOutputs)
                        }
                    }
                    .blueprintCardRow()
                }
            } header: {
                sectionHeader("100-page pack and app supplements")
            }

            Section {
                ForEach(workspace.portfolioOperatingCadence) { cadence in
                    GlassCard {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(cadence.period)
                                .font(.headline)
                                .foregroundStyle(AgenticTheme.ink)
                            Text(cadence.focus)
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                            FlowList(items: cadence.outcomes)
                        }
                    }
                    .blueprintCardRow()
                }
            } header: {
                sectionHeader("12-month operating cadence")
            }
        }
    }

    private var portfolio: some View {
        Section {
            ForEach(workspace.portfolioApps) { app in
                GlassCard {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(app.name)
                                    .font(.headline)
                                Text(app.category.rawValue)
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(AgenticTheme.emerald)
                            }
                            Spacer()
                            Text("\(app.sharedCapabilities.count) shared")
                                .font(.caption2.weight(.bold))
                                .foregroundStyle(AgenticTheme.bronze)
                        }
                        Text(app.role)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                        FlowList(items: app.targetUsers)
                    }
                }
                .blueprintCardRow()
            }
        } header: {
            sectionHeader("Extracted app portfolio")
        }
    }

    private var operatingModel: some View {
        Group {
            Section {
                ForEach(workspace.operatingFunctions) { function in
                    GlassCard {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(function.name).font(.headline)
                            Text(function.responsibility)
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                            FlowList(items: function.artifacts)
                        }
                    }
                    .blueprintCardRow()
                }
            } header: {
                sectionHeader("Product operating functions")
            }

            Section {
                ForEach(workspace.governanceRituals) { ritual in
                    GlassCard {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(ritual.focus).font(.headline)
                                Spacer()
                                Text(ritual.cadence)
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(AgenticTheme.emerald)
                            }
                            FlowList(items: ritual.outputs)
                        }
                    }
                    .blueprintCardRow()
                }
            } header: {
                sectionHeader("Governance rituals")
            }

            Section {
                ForEach(workspace.processTranslations) { translation in
                    GlassCard {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(translation.bookTheme)
                                .font(.headline)
                                .foregroundStyle(AgenticTheme.ink)
                            Text(translation.wcsTranslation)
                                .font(.footnote)
                                .foregroundStyle(AgenticTheme.ink.opacity(0.78))
                                .fixedSize(horizontal: false, vertical: true)
                            Text(translation.deliveryOutput)
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(AgenticTheme.bronze)
                        }
                    }
                    .blueprintCardRow()
                }
            } header: {
                sectionHeader("Chapter-to-workflow translation")
            }
        }
    }

    private var architecture: some View {
        Group {
            Section {
                ForEach(workspace.architectureLayers) { layer in
                    GlassCard {
                        VStack(alignment: .leading, spacing: 10) {
                            Label(layer.title, systemImage: icon(for: layer.kind))
                                .font(.headline)
                            Text(layer.purpose)
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                            FlowList(items: layer.components)
                        }
                    }
                    .blueprintCardRow()
                }
            } header: {
                sectionHeader("Full-stack topology")
            }

            Section {
                ForEach(workspace.technologyChoices) { choice in
                    GlassCard {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(choice.layer).font(.headline)
                            Text(choice.recommendation)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(AgenticTheme.emerald)
                            Text(choice.purpose)
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .blueprintCardRow()
                }
            } header: {
                sectionHeader("Recommended stack")
            }

            Section {
                ForEach(workspace.repositoryLayout) { group in
                    GlassCard {
                        VStack(alignment: .leading, spacing: 8) {
                            Label(group.path, systemImage: "folder")
                                .font(.headline)
                                .foregroundStyle(AgenticTheme.ink)
                            Text(group.purpose)
                                .font(.footnote)
                                .foregroundStyle(AgenticTheme.ink.opacity(0.78))
                                .fixedSize(horizontal: false, vertical: true)
                            FlowList(items: group.children)
                        }
                    }
                    .blueprintCardRow()
                }
            } header: {
                sectionHeader("Repository layout")
            }

            Section {
                GlassCard {
                    VStack(alignment: .leading, spacing: 8) {
                        Label(workspace.implementationStarterSummary, systemImage: "chevron.left.forwardslash.chevron.right")
                            .font(.headline)
                            .foregroundStyle(AgenticTheme.ink)
                            .fixedSize(horizontal: false, vertical: true)
                        Text("These starter artifacts preserve the implementation intent from the blueprint without replacing the live app's current entry point, services, or database code.")
                            .font(.footnote)
                            .foregroundStyle(AgenticTheme.ink.opacity(0.78))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .blueprintCardRow()

                ForEach(workspace.implementationStarterArtifacts) { artifact in
                    GlassCard {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(alignment: .firstTextBaseline) {
                                Text(artifact.title)
                                    .font(.headline)
                                    .foregroundStyle(AgenticTheme.ink)
                                Spacer()
                                Text(artifact.layer)
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(AgenticTheme.emerald)
                                    .multilineTextAlignment(.trailing)
                            }
                            Text(artifact.purpose)
                                .font(.footnote)
                                .foregroundStyle(AgenticTheme.ink.opacity(0.78))
                                .fixedSize(horizontal: false, vertical: true)
                            FlowList(items: artifact.excerpt)
                        }
                    }
                    .blueprintCardRow()
                }
            } header: {
                sectionHeader("Implementation starter artifacts")
            }

            Section {
                ForEach(workspace.scalabilityPrinciples) { principle in
                    GlassCard {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(principle.principle)
                                .font(.headline)
                                .foregroundStyle(AgenticTheme.ink)
                            Text(principle.operationalImpact)
                                .font(.footnote)
                                .foregroundStyle(AgenticTheme.ink.opacity(0.78))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    .blueprintCardRow()
                }

                ForEach(workspace.maintenancePractices) { practice in
                    GlassCard {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(practice.practice)
                                .font(.headline)
                                .foregroundStyle(AgenticTheme.ink)
                            Text(practice.evidence)
                                .font(.footnote)
                                .foregroundStyle(AgenticTheme.ink.opacity(0.78))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    .blueprintCardRow()
                }
            } header: {
                sectionHeader("Scalability and maintenance")
            }
        }
    }

    private var release: some View {
        Group {
            Section {
                GlassCard {
                    VStack(alignment: .leading, spacing: 10) {
                        Label("Launch readiness", systemImage: "flag.checkered")
                            .font(.headline)
                            .foregroundStyle(AgenticTheme.ink)
                        ProgressView(value: Double(workspace.launchReadinessPercent), total: 100)
                            .tint(AgenticTheme.emerald)
                        Text("\(workspace.launchReadinessPercent)% complete")
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(AgenticTheme.emerald)
                    }
                }
                .blueprintCardRow()

                ForEach(workspace.releaseGates) { gate in
                    GlassCard {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(alignment: .top) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(gate.title)
                                        .font(.headline)
                                        .foregroundStyle(AgenticTheme.ink)
                                    Text(gate.owner)
                                        .font(.caption)
                                        .foregroundStyle(AgenticTheme.ink.opacity(0.72))
                                }
                                Spacer()
                                statusBadge(gate.isComplete ? "Complete" : "Open", color: gate.isComplete ? AgenticTheme.emerald : AgenticTheme.bronze)
                            }
                            FlowList(items: gate.evidenceRequired)
                            Button {
                                workspace.markGateComplete(gate)
                            } label: {
                                Label("Mark complete", systemImage: "checkmark.circle")
                            }
                            .buttonStyle(.bordered)
                            .disabled(gate.isComplete)
                            .accessibilityIdentifier("blueprint.gate.\(gate.id.uuidString)")
                        }
                    }
                    .blueprintCardRow()
                }
            } header: {
                sectionHeader("CI/CD and launch gates")
            }

            Section {
                ForEach(workspace.launchPlaybook) { phase in
                    GlassCard {
                        VStack(alignment: .leading, spacing: 8) {
                            Label(phase.phase, systemImage: "paperplane")
                                .font(.headline)
                                .foregroundStyle(AgenticTheme.ink)
                            Text(phase.goal)
                                .font(.footnote)
                                .foregroundStyle(AgenticTheme.ink.opacity(0.78))
                                .fixedSize(horizontal: false, vertical: true)
                            FlowList(items: phase.actions)
                        }
                    }
                    .blueprintCardRow()
                }
            } header: {
                sectionHeader("Launch playbook")
            }

            Section {
                ForEach(workspace.deploymentRules) { rule in
                    GlassCard {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(rule.rule)
                                .font(.headline)
                                .foregroundStyle(AgenticTheme.ink)
                            Text(rule.reason)
                                .font(.footnote)
                                .foregroundStyle(AgenticTheme.ink.opacity(0.78))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    .blueprintCardRow()
                }
            } header: {
                sectionHeader("Continuous deployment rules")
            }

            Section {
                ForEach(workspace.automationSnippets) { snippet in
                    GlassCard {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(alignment: .firstTextBaseline) {
                                Text(snippet.title)
                                    .font(.headline)
                                    .foregroundStyle(AgenticTheme.ink)
                                Spacer()
                                statusBadge(snippet.tool, color: AgenticTheme.bronze)
                            }
                            Text(snippet.purpose)
                                .font(.footnote)
                                .foregroundStyle(AgenticTheme.ink.opacity(0.78))
                                .fixedSize(horizontal: false, vertical: true)
                            FlowList(items: snippet.excerpt)
                        }
                    }
                    .blueprintCardRow()
                }
            } header: {
                sectionHeader("Automation examples")
            }
        }
    }

    private var analytics: some View {
        Group {
            Section {
                ForEach(workspace.kpis) { kpi in
                    GlassCard {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(kpi.domain).font(.headline)
                            Text(kpi.purpose)
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                            FlowList(items: kpi.measures)
                        }
                    }
                    .blueprintCardRow()
                }
            } header: {
                sectionHeader("Core KPI framework")
            }

            Section {
                ForEach(workspace.dashboards) { dashboard in
                    GlassCard {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(dashboard.name).font(.headline)
                            Text(dashboard.audience)
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(AgenticTheme.emerald)
                            FlowList(items: dashboard.signals)
                        }
                    }
                    .blueprintCardRow()
                }
            } header: {
                sectionHeader("Dashboard set")
            }

            Section {
                ForEach(workspace.monitoringStack) { item in
                    GlassCard {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(alignment: .firstTextBaseline) {
                                Text(item.need)
                                    .font(.headline)
                                    .foregroundStyle(AgenticTheme.ink)
                                Spacer()
                                Text(item.toolingPattern)
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(AgenticTheme.emerald)
                                    .multilineTextAlignment(.trailing)
                            }
                            Text(item.purpose)
                                .font(.footnote)
                                .foregroundStyle(AgenticTheme.ink.opacity(0.78))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    .blueprintCardRow()
                }
            } header: {
                sectionHeader("Monitoring stack")
            }
        }
    }

    private var ethics: some View {
        Section {
            GlassCard {
                VStack(alignment: .leading, spacing: 8) {
                    Label(workspace.ethicsCoverageSummary, systemImage: "shield.checkered")
                        .font(.headline)
                    Text("Healthcare, psychosocial, and trust-sensitive workflows require privacy, least privilege, auditability, explainability, and human review before automated high-impact actions.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .blueprintCardRow()

            ForEach(workspace.ethicsControls) { control in
                GlassCard {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(control.title).font(.headline)
                        Text(control.appliesTo)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(AgenticTheme.emerald)
                        Text(control.control)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
                .blueprintCardRow()
            }
        } header: {
            sectionHeader("Ethics and healthcare safeguards")
        }
    }

    private var prompts: some View {
        Section {
            ForEach(workspace.prompts) { prompt in
                GlassCard {
                    VStack(alignment: .leading, spacing: 8) {
                        Label(prompt.title, systemImage: "text.badge.checkmark")
                            .font(.headline)
                        Text(prompt.prompt)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                        Text(prompt.expectedOutput)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(AgenticTheme.emerald)
                    }
                }
                .blueprintCardRow()
            }
        } header: {
            sectionHeader("Codex prompt pack")
        }
    }

    private var roadmap: some View {
        Section {
            ForEach(workspace.roadmap) { phase in
                GlassCard {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(phase.title).font(.headline)
                        Text(phase.objective)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                        FlowList(items: phase.deliverables)
                    }
                }
                .blueprintCardRow()
            }
        } header: {
            sectionHeader("Delivery roadmap")
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
                .blueprintCardRow()
            }
        } header: {
            sectionHeader("Blueprint audit")
        }
    }

    private func metric(_ title: String, _ value: String, _ icon: String, _ color: Color) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icon)
                .font(.title3.weight(.semibold))
                .foregroundStyle(color)
            Text(value)
                .font(.headline)
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
            .minimumScaleFactor(0.7)
    }

    private func percent(_ value: Double) -> String {
        value.formatted(.percent.precision(.fractionLength(1)))
    }

    private func sectionHeader(_ text: String) -> some View {
        Text(text)
            .font(.footnote.weight(.semibold))
            .foregroundStyle(.secondary)
            .textCase(nil)
    }

    private func icon(for layer: PlatformLayerKind) -> String {
        switch layer {
        case .iosApps: return "iphone"
        case .sharedPackages: return "shippingbox"
        case .apiGateway: return "point.3.connected.trianglepath.dotted"
        case .dataLayer: return "externaldrive.connected.to.line.below"
        case .operations: return "gearshape.2"
        }
    }
}

private enum BlueprintConsoleArea: String, CaseIterable, Identifiable {
    case overview, performance, portfolio, operatingModel, architecture, release, analytics, ethics, prompts, roadmap, audit

    var id: String { rawValue }

    var title: String {
        switch self {
        case .overview: return "Overview"
        case .performance: return "Performance"
        case .portfolio: return "Portfolio"
        case .operatingModel: return "Operating Model"
        case .architecture: return "Architecture"
        case .release: return "Release"
        case .analytics: return "Analytics"
        case .ethics: return "Ethics"
        case .prompts: return "Prompts"
        case .roadmap: return "Roadmap"
        case .audit: return "Audit"
        }
    }

    var systemImage: String {
        switch self {
        case .overview: return "rectangle.grid.2x2"
        case .performance: return "chart.line.uptrend.xyaxis"
        case .portfolio: return "square.grid.3x3"
        case .operatingModel: return "person.3.sequence"
        case .architecture: return "point.3.connected.trianglepath.dotted"
        case .release: return "flag.checkered"
        case .analytics: return "chart.xyaxis.line"
        case .ethics: return "shield.checkered"
        case .prompts: return "text.badge.checkmark"
        case .roadmap: return "map"
        case .audit: return "clock.badge.checkmark"
        }
    }
}

private struct FlowList: View {
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
    func blueprintCardRow() -> some View {
        listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
    }
}

//
//  PlatformBlueprintWorkspace.swift
//  WCS-Agentic
//

import Combine
import Foundation

@MainActor
final class PlatformBlueprintWorkspace: ObservableObject {
    private let monitoringEngine = PostLaunchMonitoringEngine()

    @Published private(set) var portfolioApps: [PortfolioAppProfile]
    @Published private(set) var postLaunchProfiles: [PostLaunchAppPerformanceProfile]
    @Published private(set) var postLaunchSnapshots: [PostLaunchWeeklySnapshot]
    @Published private(set) var postLaunchScorecardSignals: [String]
    @Published private(set) var postLaunchEventTaxonomy: [EventTaxonomyGroup]
    @Published private(set) var supportServiceLevels: [SupportServiceLevel]
    @Published private(set) var portfolioOperatingCadence: [PortfolioOperatingCadence]
    @Published private(set) var processTranslations: [ProcessGroupTranslation]
    @Published private(set) var launchPlaybook: [LaunchPlaybookPhase]
    @Published private(set) var repositoryLayout: [RepositoryLayoutGroup]
    @Published private(set) var monitoringStack: [MonitoringStackItem]
    @Published private(set) var deploymentRules: [ContinuousDeploymentRule]
    @Published private(set) var portfolioReviewLoops: [PortfolioReviewLoop]
    @Published private(set) var telemetryLayers: [TelemetryLayerSpec]
    @Published private(set) var reviewOperations: [ReviewOperationsSpec]
    @Published private(set) var supportTaxonomyFields: [SupportTaxonomyField]
    @Published private(set) var riskEthicsFocusAreas: [RiskEthicsFocusArea]
    @Published private(set) var reportAssemblyPlan: [ReportAssemblyItem]
    @Published private(set) var appSupplements: [AppSupplementSpec]
    @Published private(set) var implementationStarterArtifacts: [ImplementationStarterArtifact]
    @Published private(set) var scalabilityPrinciples: [ScalabilityPrinciple]
    @Published private(set) var maintenancePractices: [MaintenancePractice]
    @Published private(set) var automationSnippets: [AutomationSnippet]
    @Published private(set) var operatingFunctions: [ProductOperatingFunction]
    @Published private(set) var governanceRituals: [GovernanceRitual]
    @Published private(set) var architectureLayers: [PlatformArchitectureLayer]
    @Published private(set) var technologyChoices: [TechnologyChoice]
    @Published private(set) var releaseGates: [ReleaseReadinessGate]
    @Published private(set) var kpis: [ProductKPI]
    @Published private(set) var dashboards: [DashboardSpec]
    @Published private(set) var ethicsControls: [EthicsControl]
    @Published private(set) var prompts: [BlueprintPrompt]
    @Published private(set) var roadmap: [BlueprintRoadmapPhase]
    @Published private(set) var auditTrail: [AuditEvent]

    init(seed: PlatformBlueprintSeed = .demo) {
        portfolioApps = seed.portfolioApps
        postLaunchProfiles = seed.postLaunchProfiles
        postLaunchSnapshots = PostLaunchMonitoringEngine.demoSnapshots(for: seed.postLaunchProfiles)
        postLaunchScorecardSignals = seed.postLaunchScorecardSignals
        postLaunchEventTaxonomy = seed.postLaunchEventTaxonomy
        supportServiceLevels = seed.supportServiceLevels
        portfolioOperatingCadence = seed.portfolioOperatingCadence
        processTranslations = seed.processTranslations
        launchPlaybook = seed.launchPlaybook
        repositoryLayout = seed.repositoryLayout
        monitoringStack = seed.monitoringStack
        deploymentRules = seed.deploymentRules
        portfolioReviewLoops = seed.portfolioReviewLoops
        telemetryLayers = seed.telemetryLayers
        reviewOperations = seed.reviewOperations
        supportTaxonomyFields = seed.supportTaxonomyFields
        riskEthicsFocusAreas = seed.riskEthicsFocusAreas
        reportAssemblyPlan = seed.reportAssemblyPlan
        appSupplements = seed.appSupplements
        implementationStarterArtifacts = seed.implementationStarterArtifacts
        scalabilityPrinciples = seed.scalabilityPrinciples
        maintenancePractices = seed.maintenancePractices
        automationSnippets = seed.automationSnippets
        operatingFunctions = seed.operatingFunctions
        governanceRituals = seed.governanceRituals
        architectureLayers = seed.architectureLayers
        technologyChoices = seed.technologyChoices
        releaseGates = seed.releaseGates
        kpis = seed.kpis
        dashboards = seed.dashboards
        ethicsControls = seed.ethicsControls
        prompts = seed.prompts
        roadmap = seed.roadmap
        auditTrail = [
            AuditEvent(
                id: UUID(),
                timestamp: Date(),
                actor: "product.ops@worldclassscholars.test",
                action: "Loaded WCS platform blueprint",
                object: "Portfolio operating model",
                rationale: "Initialized shared portfolio model, release gates, analytics, architecture, and ethics controls."
            )
        ]
    }

    var launchReadinessPercent: Int {
        guard !releaseGates.isEmpty else { return 0 }
        let completed = releaseGates.filter(\.isComplete).count
        return Int((Double(completed) / Double(releaseGates.count) * 100).rounded())
    }

    var openReleaseGates: [ReleaseReadinessGate] {
        releaseGates.filter { !$0.isComplete }
    }

    var nextReleaseAction: String {
        guard let gate = openReleaseGates.first else {
            return "All launch readiness gates are complete. Prepare phased rollout and post-release review."
        }
        return "Complete \(gate.title) with \(gate.evidenceRequired.joined(separator: ", "))."
    }

    var medicalAppCount: Int {
        portfolioApps.filter { $0.category == .medical }.count
    }

    var sharedCapabilityCount: Int {
        Set(portfolioApps.flatMap(\.sharedCapabilities)).count
    }

    var livePortfolioCount: Int {
        postLaunchProfiles.filter { $0.publicStatus.localizedCaseInsensitiveContains("live") }.count
    }

    var paidPostLaunchProfiles: [PostLaunchAppPerformanceProfile] {
        postLaunchProfiles.filter(\.isPaid)
    }

    var zeroRatingProfiles: [PostLaunchAppPerformanceProfile] {
        postLaunchProfiles.filter(\.needsRatingsGeneration)
    }

    var totalVisibleRatings: Int {
        postLaunchProfiles.reduce(0) { $0 + $1.visibleRatingCount }
    }

    var highestVisiblePriceProfile: PostLaunchAppPerformanceProfile? {
        paidPostLaunchProfiles.max {
            (Double($0.priceAUD) ?? 0) < (Double($1.priceAUD) ?? 0)
        }
    }

    var postLaunchRiskSummary: String {
        guard !postLaunchProfiles.isEmpty else { return "No live app monitoring data loaded" }
        if zeroRatingProfiles.count == postLaunchProfiles.count {
            return "Ratings generation is urgent across the live portfolio."
        }
        if zeroRatingProfiles.isEmpty {
            return "All live products have visible rating proof."
        }
        return "\(zeroRatingProfiles.count) apps need rating-generation attention."
    }

    var installedMonitoringEngines: [MonitoringEngineDescriptor] {
        monitoringEngine.descriptors
    }

    var portfolioScorecard: PortfolioScorecard {
        monitoringEngine.scorecard(snapshots: postLaunchSnapshots, profiles: postLaunchProfiles)
    }

    var ratingPromptDecisions: [RatingPromptDecision] {
        postLaunchProfiles.compactMap { profile in
            guard let snapshot = postLaunchSnapshot(named: profile.appName) else { return nil }
            return monitoringEngine.ratingPromptDecision(snapshot: snapshot, profile: profile)
        }
    }

    var ratingPromptQueue: [RatingPromptDecision] {
        ratingPromptDecisions.filter(\.shouldPrompt)
    }

    var reviewTriageDemo: ReviewTriageResult {
        monitoringEngine.reviewTriage(
            appName: "TruthLens Global",
            reviewText: "I need clearer sources because a political claim looked wrong.",
            starRating: 2
        )
    }

    var supportTriageDemo: SupportTriageResult? {
        let appName = "Psychosocial Analytics"
        guard let profile = postLaunchProfile(named: appName) ?? postLaunchProfiles.first else {
            return nil
        }
        return monitoringEngine.supportTriage(
            ticket: SupportTicketInput(
                appName: appName,
                issueType: "Paid export workflow blocker",
                severity: .warning,
                appVersion: "1.0",
                deviceOS: "iOS 18"
            ),
            profile: profile
        )
    }

    var roadmapRecommendations: [RoadmapRecommendation] {
        postLaunchProfiles.compactMap { profile in
            guard let snapshot = postLaunchSnapshot(named: profile.appName) else { return nil }
            return monitoringEngine.roadmapRecommendation(snapshot: snapshot, profile: profile)
        }
    }

    var telemetryCoverageReports: [TelemetryCoverageReport] {
        postLaunchProfiles.map { profile in
            let observedEvents = Array(
                Set(
                    profile.instrumentationEvents
                        + postLaunchEventTaxonomy.prefix(3).flatMap(\.exampleEvents)
                )
            )
            return monitoringEngine.telemetryCoverage(
                profile: profile,
                taxonomy: postLaunchEventTaxonomy,
                observedEvents: observedEvents
            )
        }
    }

    var postLaunchEngineStatusSummary: String {
        let scorecard = portfolioScorecard
        return "\(installedMonitoringEngines.count) engines installed. \(scorecard.riskSummary)"
    }

    var blueprintCoverageSummary: String {
        let coverageCount = processTranslations.count + launchPlaybook.count + repositoryLayout.count + monitoringStack.count
        return "\(coverageCount) DPM blueprint objects loaded across workflow translation, launch, repository, and observability."
    }

    var executionPackSummary: String {
        "\(appSupplements.count) app supplements and \(reportAssemblyPlan.count) report assembly sections ready for the 100-page portfolio pack."
    }

    var implementationStarterSummary: String {
        "\(implementationStarterArtifacts.count) starter artifacts cover iOS routing, agent execution, backend endpoints, database schema, and analytics payloads."
    }

    var ethicsCoverageSummary: String {
        let hasPrivacy = ethicsControls.contains { $0.title.localizedCaseInsensitiveContains("privacy") }
        let hasHumanReview = ethicsControls.contains { $0.title.localizedCaseInsensitiveContains("human") }
        let hasAudit = ethicsControls.contains { $0.title.localizedCaseInsensitiveContains("audit") }
        return hasPrivacy && hasHumanReview && hasAudit ? "Core controls present" : "Review required"
    }

    func apps(in category: PortfolioAppCategory) -> [PortfolioAppProfile] {
        portfolioApps.filter { $0.category == category }
    }

    func architectureLayer(_ kind: PlatformLayerKind) -> PlatformArchitectureLayer? {
        architectureLayers.first { $0.kind == kind }
    }

    func postLaunchProfile(named name: String) -> PostLaunchAppPerformanceProfile? {
        postLaunchProfiles.first { $0.appName == name }
    }

    func postLaunchSnapshot(named name: String) -> PostLaunchWeeklySnapshot? {
        postLaunchSnapshots.first { $0.appName == name }
    }

    func reviewTriage(appName: String, reviewText: String, starRating: Int) -> ReviewTriageResult {
        monitoringEngine.reviewTriage(appName: appName, reviewText: reviewText, starRating: starRating)
    }

    func supportTriage(ticket: SupportTicketInput) -> SupportTriageResult? {
        guard let profile = postLaunchProfile(named: ticket.appName) else { return nil }
        return monitoringEngine.supportTriage(ticket: ticket, profile: profile)
    }

    func markGateComplete(_ gate: ReleaseReadinessGate, actor: String = "product.ops@worldclassscholars.test") {
        guard let index = releaseGates.firstIndex(where: { $0.id == gate.id }) else { return }
        guard !releaseGates[index].isComplete else { return }
        releaseGates[index].isComplete = true
        log(
            actor: actor,
            action: "Completed release gate",
            object: gate.title,
            rationale: "Evidence captured: \(gate.evidenceRequired.joined(separator: ", "))."
        )
    }

    func completeNextGate(actor: String = "product.ops@worldclassscholars.test") {
        guard let gate = openReleaseGates.first else { return }
        markGateComplete(gate, actor: actor)
    }

    func resetReleaseGates(actor: String = "product.ops@worldclassscholars.test") {
        for index in releaseGates.indices {
            releaseGates[index].isComplete = index == 0 || releaseGates[index].title == "Release candidate tested"
        }
        log(
            actor: actor,
            action: "Reset release gates",
            object: "Launch readiness",
            rationale: "Restored blueprint demo state for launch planning."
        )
    }

    private func log(actor: String, action: String, object: String, rationale: String) {
        auditTrail.insert(
            AuditEvent(
                id: UUID(),
                timestamp: Date(),
                actor: actor,
                action: action,
                object: object,
                rationale: rationale
            ),
            at: 0
        )
    }
}

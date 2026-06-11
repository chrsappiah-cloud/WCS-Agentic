//
//  PlatformBlueprintWorkspaceTests.swift
//  WCS-AgenticTests
//

import XCTest
@testable import WCS_Agentic

@MainActor
final class PlatformBlueprintWorkspaceTests: XCTestCase {
    private var workspace: PlatformBlueprintWorkspace!

    override func setUp() {
        super.setUp()
        workspace = PlatformBlueprintWorkspace()
    }

    override func tearDown() {
        workspace = nil
        super.tearDown()
    }

    func testPortfolioIncludesAllBlueprintApps() {
        let names = Set(workspace.portfolioApps.map(\.name))

        XCTAssertEqual(workspace.portfolioApps.count, 7)
        XCTAssertTrue(names.contains("AgedCare Monitor"))
        XCTAssertTrue(names.contains("CareLens Aged+"))
        XCTAssertTrue(names.contains("PeaceLens"))
        XCTAssertTrue(names.contains("Psychosocial Analytics"))
        XCTAssertTrue(names.contains("TruthLens Global"))
        XCTAssertTrue(names.contains("WCS-Tatto"))
        XCTAssertTrue(names.contains("WCSLIB"))
    }

    func testSharedPlatformCapabilitiesAreReusableAcrossApps() {
        XCTAssertGreaterThanOrEqual(workspace.sharedCapabilityCount, 6)
        XCTAssertEqual(workspace.medicalAppCount, 3)
        XCTAssertFalse(workspace.apps(in: .education).isEmpty)
    }

    func testLaunchReadinessImprovesWhenGateCompletes() {
        let initial = workspace.launchReadinessPercent
        let openGate = workspace.openReleaseGates.first!

        workspace.markGateComplete(openGate, actor: "unit.product.ops@test.wcs")

        XCTAssertGreaterThan(workspace.launchReadinessPercent, initial)
        XCTAssertEqual(workspace.auditTrail.first?.actor, "unit.product.ops@test.wcs")
    }

    func testEthicsControlsCoverPrivacyAuditAndHumanReview() {
        let titles = workspace.ethicsControls.map(\.title).joined(separator: " ")

        XCTAssertEqual(workspace.ethicsCoverageSummary, "Core controls present")
        XCTAssertTrue(titles.localizedCaseInsensitiveContains("privacy"))
        XCTAssertTrue(titles.localizedCaseInsensitiveContains("audit"))
        XCTAssertTrue(titles.localizedCaseInsensitiveContains("human"))
    }

    func testBlueprintRoadmapAndPromptPackExposeImplementationPriorities() {
        XCTAssertEqual(workspace.roadmap.first?.title, "Phase 1: platform foundation")
        XCTAssertTrue(workspace.prompts.contains { $0.title == "Portfolio scaffold" })
        XCTAssertTrue(workspace.prompts.contains { $0.title == "Agentic workflow engine" })
    }

    func testArchitectureContainsSharedPackagesAndOperationsLayer() {
        let packages = workspace.architectureLayer(.sharedPackages)
        let ops = workspace.architectureLayer(.operations)

        XCTAssertTrue(packages?.components.contains("WCSAnalytics") == true)
        XCTAssertTrue(packages?.components.contains("WCSFeatureFlags") == true)
        XCTAssertTrue(ops?.components.contains("CI/CD") == true)
    }

    func testPostLaunchProfilesMatchLiveStoreInventory() {
        let names = Set(workspace.postLaunchProfiles.map(\.appName))

        XCTAssertEqual(workspace.postLaunchProfiles.count, 7)
        XCTAssertEqual(workspace.livePortfolioCount, 7)
        XCTAssertEqual(workspace.totalVisibleRatings, 0)
        XCTAssertTrue(names.contains("AgedCare Monitor"))
        XCTAssertTrue(names.contains("TruthLens Global"))
        XCTAssertEqual(workspace.postLaunchProfile(named: "CareLens Aged+")?.priceAUD, "12.99")
        XCTAssertEqual(workspace.postLaunchProfile(named: "Psychosocial Analytics")?.priceAUD, "24.99")
    }

    func testZeroRatingAppsDriveReviewGenerationPriority() {
        XCTAssertEqual(workspace.zeroRatingProfiles.count, workspace.postLaunchProfiles.count)
        XCTAssertTrue(workspace.postLaunchRiskSummary.localizedCaseInsensitiveContains("urgent"))
        XCTAssertTrue(workspace.postLaunchProfiles.allSatisfy(\.needsRatingsGeneration))
    }

    func testHighestVisiblePriceAndPaidPortfolioAreDetected() {
        XCTAssertEqual(workspace.paidPostLaunchProfiles.count, 5)
        XCTAssertEqual(workspace.highestVisiblePriceProfile?.appName, "Psychosocial Analytics")
    }

    func testInstrumentationAndSupportOperatingCadenceAreLoaded() {
        let taxonomyGroups = Set(workspace.postLaunchEventTaxonomy.map(\.group))

        XCTAssertTrue(taxonomyGroups.contains("Acquisition"))
        XCTAssertTrue(taxonomyGroups.contains("Trust"))
        XCTAssertTrue(workspace.postLaunchScorecardSignals.contains("average rating and rating count"))
        XCTAssertTrue(workspace.supportServiceLevels.contains { $0.issueType == "Paid app workflow blocker" })
        XCTAssertEqual(workspace.portfolioOperatingCadence.first?.period, "Month 1 to 2")
    }

    func testPastedDPMWorkflowTranslationsAreLoaded() {
        let themes = Set(workspace.processTranslations.map(\.bookTheme))
        let outputs = Set(workspace.processTranslations.map(\.deliveryOutput))

        XCTAssertGreaterThanOrEqual(workspace.processTranslations.count, 10)
        XCTAssertTrue(themes.contains("Digital Product Management Overview"))
        XCTAssertTrue(themes.contains("Supporting and Maintaining Products"))
        XCTAssertTrue(themes.contains("Ethics and Continuous Improvement"))
        XCTAssertTrue(outputs.contains("Portfolio charter"))
        XCTAssertTrue(outputs.contains("Support and maintenance handbook"))
        XCTAssertTrue(workspace.blueprintCoverageSummary.localizedCaseInsensitiveContains("DPM blueprint"))
    }

    func testLaunchPlaybookDeploymentRulesAndAutomationExamplesAreLoaded() {
        let phases = Set(workspace.launchPlaybook.map(\.phase))
        let snippetTitles = Set(workspace.automationSnippets.map(\.title))

        XCTAssertEqual(workspace.launchPlaybook.count, 3)
        XCTAssertTrue(phases.contains("Pre-launch"))
        XCTAssertTrue(phases.contains("Launch"))
        XCTAssertTrue(phases.contains("Post-launch"))
        XCTAssertTrue(workspace.deploymentRules.contains { $0.rule.localizedCaseInsensitiveContains("feature flag") })
        XCTAssertTrue(workspace.deploymentRules.contains { $0.rule.localizedCaseInsensitiveContains("phased release") })
        XCTAssertTrue(snippetTitles.contains("GitHub Actions iOS CI"))
        XCTAssertTrue(snippetTitles.contains("Fastlane release lane"))
    }

    func testRepositoryLayoutAndMonitoringStackAreLoaded() {
        let paths = Set(workspace.repositoryLayout.map(\.path))
        let monitoringNeeds = Set(workspace.monitoringStack.map(\.need))

        XCTAssertTrue(paths.contains("apps/"))
        XCTAssertTrue(paths.contains("packages/"))
        XCTAssertTrue(paths.contains("backend/"))
        XCTAssertTrue(paths.contains("infra/"))
        XCTAssertTrue(workspace.repositoryLayout.contains { $0.children.contains("TruthLensGlobal-iOS") })
        XCTAssertTrue(workspace.repositoryLayout.contains { $0.children.contains("WCSAnalytics") })
        XCTAssertTrue(monitoringNeeds.contains("Client crashes"))
        XCTAssertTrue(monitoringNeeds.contains("Product analytics"))
        XCTAssertTrue(workspace.monitoringStack.contains { $0.toolingPattern.localizedCaseInsensitiveContains("Sentry") })
    }

    func testImplementationStarterArtifactsAreLoaded() {
        let artifactTitles = Set(workspace.implementationStarterArtifacts.map(\.title))

        XCTAssertEqual(workspace.implementationStarterArtifacts.count, 6)
        XCTAssertTrue(artifactTitles.contains("SwiftUI app shell"))
        XCTAssertTrue(artifactTitles.contains("Root routing"))
        XCTAssertTrue(artifactTitles.contains("Agent task protocol"))
        XCTAssertTrue(artifactTitles.contains("Fastify backend starter"))
        XCTAssertTrue(artifactTitles.contains("Database starter schema"))
        XCTAssertTrue(artifactTitles.contains("Event payload starter"))
        XCTAssertTrue(workspace.implementationStarterArtifacts.contains { $0.excerpt.contains("POST /v1/events returns ingested count") })
        XCTAssertTrue(workspace.implementationStarterSummary.localizedCaseInsensitiveContains("starter artifacts"))
    }

    func testScalabilityAndMaintenancePrinciplesAreLoaded() {
        XCTAssertEqual(workspace.scalabilityPrinciples.count, 5)
        XCTAssertEqual(workspace.maintenancePractices.count, 4)
        XCTAssertTrue(workspace.scalabilityPrinciples.contains { $0.principle.localizedCaseInsensitiveContains("stateless") })
        XCTAssertTrue(workspace.scalabilityPrinciples.contains { $0.principle.localizedCaseInsensitiveContains("Queue expensive jobs") })
        XCTAssertTrue(workspace.maintenancePractices.contains { $0.practice.localizedCaseInsensitiveContains("rollback guides") })
        XCTAssertTrue(workspace.maintenancePractices.contains { $0.practice.localizedCaseInsensitiveContains("technical debt") })
    }

    func testPortfolioReviewLoopsAndTelemetryLayersAreLoaded() {
        let loopCadences = Set(workspace.portfolioReviewLoops.map(\.cadence))
        let telemetryLayerNames = Set(workspace.telemetryLayers.map(\.layer))

        XCTAssertEqual(workspace.portfolioReviewLoops.count, 3)
        XCTAssertTrue(loopCadences.contains("Weekly dashboard"))
        XCTAssertTrue(loopCadences.contains("Monthly business review"))
        XCTAssertTrue(loopCadences.contains("Quarterly roadmap review"))
        XCTAssertTrue(workspace.portfolioReviewLoops.contains { $0.decisions.contains("core value event completion rate") })
        XCTAssertTrue(telemetryLayerNames.contains("App Store Connect metrics"))
        XCTAssertTrue(telemetryLayerNames.contains("Crash and performance telemetry"))
        XCTAssertTrue(workspace.telemetryLayers.contains { $0.captures.contains("memory pressure") })
    }

    func testReviewSupportAndRiskExecutionPackIsLoaded() {
        let operationNames = Set(workspace.reviewOperations.map(\.workflow))
        let supportFields = Set(workspace.supportTaxonomyFields.map(\.field))
        let riskGroups = Set(workspace.riskEthicsFocusAreas.map(\.productGroup))

        XCTAssertTrue(operationNames.contains("Ratings generation"))
        XCTAssertTrue(operationNames.contains("Review response triage"))
        XCTAssertTrue(workspace.reviewOperations.contains { $0.practices.contains("suppress prompts after recent errors") })
        XCTAssertTrue(supportFields.contains("App name"))
        XCTAssertTrue(supportFields.contains("Root cause"))
        XCTAssertTrue(riskGroups.contains("Health apps"))
        XCTAssertTrue(riskGroups.contains("Civic/news app"))
        XCTAssertTrue(riskGroups.contains("Education and lifestyle apps"))
    }

    func testHundredPageReportAssemblyAndAppSupplementsAreLoaded() {
        let reportSections = Set(workspace.reportAssemblyPlan.map(\.section))
        let supplementNames = Set(workspace.appSupplements.map(\.appName))

        XCTAssertEqual(workspace.appSupplements.count, 7)
        XCTAssertTrue(workspace.executionPackSummary.localizedCaseInsensitiveContains("100-page portfolio pack"))
        XCTAssertTrue(reportSections.contains("Portfolio overview"))
        XCTAssertTrue(reportSections.contains("Evidence appendices"))
        XCTAssertTrue(workspace.reportAssemblyPlan.contains { $0.contents.contains("screenshots") })
        XCTAssertTrue(supplementNames.contains("AgedCare Monitor"))
        XCTAssertTrue(supplementNames.contains("TruthLens Global"))
        XCTAssertTrue(supplementNames.contains("WCSLIB"))
        XCTAssertTrue(workspace.appSupplements.contains { $0.supplementOutputs.contains("claim-scan funnel") })
    }

    func testPostLaunchMonitoringEnginesAreInstalled() {
        let engineNames = Set(workspace.installedMonitoringEngines.map(\.name))

        XCTAssertEqual(workspace.installedMonitoringEngines.count, 6)
        XCTAssertTrue(engineNames.contains("Weekly scorecard engine"))
        XCTAssertTrue(engineNames.contains("Rating generation engine"))
        XCTAssertTrue(engineNames.contains("Review triage engine"))
        XCTAssertTrue(engineNames.contains("Support SLA engine"))
        XCTAssertTrue(engineNames.contains("Roadmap decision engine"))
        XCTAssertTrue(engineNames.contains("Telemetry coverage engine"))
    }

    func testPostLaunchScorecardAggregatesWeeklySnapshots() {
        let scorecard = workspace.portfolioScorecard

        XCTAssertEqual(workspace.postLaunchSnapshots.count, 7)
        XCTAssertEqual(scorecard.appCount, 7)
        XCTAssertGreaterThan(scorecard.totalNewInstalls, 0)
        XCTAssertEqual(scorecard.totalRatingCount, 0)
        XCTAssertEqual(scorecard.zeroRatingAppNames.count, 7)
        XCTAssertTrue(scorecard.riskSummary.localizedCaseInsensitiveContains("ratings"))
    }

    func testRatingPromptEngineSuppressesAfterRecentErrors() {
        let psychosocialDecision = workspace.ratingPromptDecisions.first {
            $0.appName == "Psychosocial Analytics"
        }
        let agedCareDecision = workspace.ratingPromptDecisions.first {
            $0.appName == "AgedCare Monitor"
        }

        XCTAssertEqual(psychosocialDecision?.shouldPrompt, false)
        XCTAssertTrue(psychosocialDecision?.reason.localizedCaseInsensitiveContains("quality") == true)
        XCTAssertEqual(agedCareDecision?.shouldPrompt, true)
        XCTAssertFalse(workspace.ratingPromptQueue.contains { $0.appName == "Psychosocial Analytics" })
    }

    func testReviewAndSupportTriageEnginesRouteRisk() {
        let review = workspace.reviewTriage(
            appName: "TruthLens Global",
            reviewText: "The source looked wrong and I need privacy clarity.",
            starRating: 2
        )
        let support = workspace.supportTriage(
            ticket: SupportTicketInput(
                appName: "CareLens Aged+",
                issueType: "Billing and export workflow blocker",
                severity: .warning,
                appVersion: "1.0",
                deviceOS: "iOS 18"
            )
        )

        XCTAssertEqual(review.category, .trustConcern)
        XCTAssertEqual(review.route, "Governance and trust review")
        XCTAssertEqual(support?.targetResponse, "Within one business day")
        XCTAssertTrue(support?.escalation.localizedCaseInsensitiveContains("privacy") == true)
    }

    func testRoadmapEngineRecommendsStabilizationForReliabilityRisk() {
        let psychosocialRecommendation = workspace.roadmapRecommendations.first {
            $0.appName == "Psychosocial Analytics"
        }

        XCTAssertEqual(psychosocialRecommendation?.decision, .stabilize)
        XCTAssertTrue(psychosocialRecommendation?.actions.contains("Prioritize crash and sync fixes") == true)
    }

    func testTelemetryCoverageEngineFindsMissingRequiredEvents() {
        let truthLensCoverage = workspace.telemetryCoverageReports.first {
            $0.appName == "TruthLens Global"
        }

        XCTAssertEqual(workspace.telemetryCoverageReports.count, 7)
        XCTAssertEqual(truthLensCoverage?.isComplete, false)
        XCTAssertTrue(truthLensCoverage?.requiredEvents.contains("source_clicked") == true)
        XCTAssertTrue(truthLensCoverage?.missingEvents.contains("source_clicked") == true)
    }
}

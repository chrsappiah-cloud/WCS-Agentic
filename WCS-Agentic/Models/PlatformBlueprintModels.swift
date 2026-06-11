//
//  PlatformBlueprintModels.swift
//  WCS-Agentic
//

import Foundation

enum PortfolioAppCategory: String, Codable, CaseIterable, Identifiable {
    case medical = "Medical"
    case education = "Education"
    case news = "News"
    case lifestyle = "Lifestyle"

    var id: String { rawValue }
}

struct PortfolioAppProfile: Codable, Identifiable, Hashable {
    let id: UUID
    let name: String
    let category: PortfolioAppCategory
    let role: String
    let targetUsers: [String]
    let sharedCapabilities: [String]
}

struct ProductOperatingFunction: Codable, Identifiable, Hashable {
    let id: UUID
    let name: String
    let responsibility: String
    let artifacts: [String]
}

struct GovernanceRitual: Codable, Identifiable, Hashable {
    let id: UUID
    let cadence: String
    let focus: String
    let outputs: [String]
}

enum PlatformLayerKind: String, Codable, CaseIterable, Identifiable {
    case iosApps = "iOS apps"
    case sharedPackages = "Shared packages"
    case apiGateway = "API gateway"
    case dataLayer = "Data layer"
    case operations = "Operations"

    var id: String { rawValue }
}

struct PlatformArchitectureLayer: Codable, Identifiable, Hashable {
    let id: UUID
    let kind: PlatformLayerKind
    let title: String
    let components: [String]
    let purpose: String
}

struct TechnologyChoice: Codable, Identifiable, Hashable {
    let id: UUID
    let layer: String
    let recommendation: String
    let purpose: String
}

struct ReleaseReadinessGate: Codable, Identifiable, Hashable {
    let id: UUID
    let title: String
    let owner: String
    let evidenceRequired: [String]
    var isComplete: Bool
}

struct ProductKPI: Codable, Identifiable, Hashable {
    let id: UUID
    let domain: String
    let measures: [String]
    let purpose: String
}

struct PerformanceKPIGroup: Codable, Identifiable, Hashable {
    let id: UUID
    let domain: String
    let measures: [String]
    let purpose: String
}

struct PostLaunchAppPerformanceProfile: Codable, Identifiable, Hashable {
    let id: UUID
    let appName: String
    let category: PortfolioAppCategory
    let priceAUD: String
    let publicStatus: String
    let visibleRatingCount: Int
    let productMandate: String
    let northStarGoal: String
    let kpiGroups: [PerformanceKPIGroup]
    let instrumentationEvents: [String]
    let appStoreActions: [String]
    let uxWatchpoints: [String]
    let supportActions: [String]
    let retentionActions: [String]
    let releaseCadence: String
    let roadmapWaves: [String]
    let monthlyReviewQuestions: [String]

    var isPaid: Bool {
        !priceAUD.localizedCaseInsensitiveContains("free")
            && !priceAUD.localizedCaseInsensitiveContains("not fully")
    }

    var needsRatingsGeneration: Bool {
        visibleRatingCount == 0
    }
}

struct EventTaxonomyGroup: Codable, Identifiable, Hashable {
    let id: UUID
    let group: String
    let exampleEvents: [String]
    let purpose: String
}

struct SupportServiceLevel: Codable, Identifiable, Hashable {
    let id: UUID
    let issueType: String
    let targetResponse: String
}

struct PortfolioOperatingCadence: Codable, Identifiable, Hashable {
    let id: UUID
    let period: String
    let focus: String
    let outcomes: [String]
}

struct ProcessGroupTranslation: Codable, Identifiable, Hashable {
    let id: UUID
    let bookTheme: String
    let wcsTranslation: String
    let deliveryOutput: String
}

struct LaunchPlaybookPhase: Codable, Identifiable, Hashable {
    let id: UUID
    let phase: String
    let goal: String
    let actions: [String]
}

struct RepositoryLayoutGroup: Codable, Identifiable, Hashable {
    let id: UUID
    let path: String
    let purpose: String
    let children: [String]
}

struct MonitoringStackItem: Codable, Identifiable, Hashable {
    let id: UUID
    let need: String
    let toolingPattern: String
    let purpose: String
}

struct ContinuousDeploymentRule: Codable, Identifiable, Hashable {
    let id: UUID
    let rule: String
    let reason: String
}

struct PortfolioReviewLoop: Codable, Identifiable, Hashable {
    let id: UUID
    let cadence: String
    let focus: String
    let decisions: [String]
}

struct TelemetryLayerSpec: Codable, Identifiable, Hashable {
    let id: UUID
    let layer: String
    let captures: [String]
    let managementUse: String
}

struct ReviewOperationsSpec: Codable, Identifiable, Hashable {
    let id: UUID
    let workflow: String
    let practices: [String]
}

struct SupportTaxonomyField: Codable, Identifiable, Hashable {
    let id: UUID
    let field: String
    let purpose: String
}

struct RiskEthicsFocusArea: Codable, Identifiable, Hashable {
    let id: UUID
    let productGroup: String
    let controls: [String]
}

struct ReportAssemblyItem: Codable, Identifiable, Hashable {
    let id: UUID
    let section: String
    let contents: [String]
}

struct AppSupplementSpec: Codable, Identifiable, Hashable {
    let id: UUID
    let appName: String
    let supplementOutputs: [String]
}

struct ImplementationStarterArtifact: Codable, Identifiable, Hashable {
    let id: UUID
    let title: String
    let layer: String
    let purpose: String
    let excerpt: [String]
}

struct ScalabilityPrinciple: Codable, Identifiable, Hashable {
    let id: UUID
    let principle: String
    let operationalImpact: String
}

struct MaintenancePractice: Codable, Identifiable, Hashable {
    let id: UUID
    let practice: String
    let evidence: String
}

struct AutomationSnippet: Codable, Identifiable, Hashable {
    let id: UUID
    let title: String
    let tool: String
    let purpose: String
    let excerpt: [String]
}

struct DashboardSpec: Codable, Identifiable, Hashable {
    let id: UUID
    let name: String
    let audience: String
    let signals: [String]
}

struct EthicsControl: Codable, Identifiable, Hashable {
    let id: UUID
    let title: String
    let appliesTo: String
    let control: String
}

struct BlueprintPrompt: Codable, Identifiable, Hashable {
    let id: UUID
    let title: String
    let prompt: String
    let expectedOutput: String
}

struct BlueprintRoadmapPhase: Codable, Identifiable, Hashable {
    let id: UUID
    let title: String
    let objective: String
    let deliverables: [String]
}

struct PlatformBlueprintSeed {
    let portfolioApps: [PortfolioAppProfile]
    let postLaunchProfiles: [PostLaunchAppPerformanceProfile]
    let postLaunchScorecardSignals: [String]
    let postLaunchEventTaxonomy: [EventTaxonomyGroup]
    let supportServiceLevels: [SupportServiceLevel]
    let portfolioOperatingCadence: [PortfolioOperatingCadence]
    let processTranslations: [ProcessGroupTranslation]
    let launchPlaybook: [LaunchPlaybookPhase]
    let repositoryLayout: [RepositoryLayoutGroup]
    let monitoringStack: [MonitoringStackItem]
    let deploymentRules: [ContinuousDeploymentRule]
    let portfolioReviewLoops: [PortfolioReviewLoop]
    let telemetryLayers: [TelemetryLayerSpec]
    let reviewOperations: [ReviewOperationsSpec]
    let supportTaxonomyFields: [SupportTaxonomyField]
    let riskEthicsFocusAreas: [RiskEthicsFocusArea]
    let reportAssemblyPlan: [ReportAssemblyItem]
    let appSupplements: [AppSupplementSpec]
    let implementationStarterArtifacts: [ImplementationStarterArtifact]
    let scalabilityPrinciples: [ScalabilityPrinciple]
    let maintenancePractices: [MaintenancePractice]
    let automationSnippets: [AutomationSnippet]
    let operatingFunctions: [ProductOperatingFunction]
    let governanceRituals: [GovernanceRitual]
    let architectureLayers: [PlatformArchitectureLayer]
    let technologyChoices: [TechnologyChoice]
    let releaseGates: [ReleaseReadinessGate]
    let kpis: [ProductKPI]
    let dashboards: [DashboardSpec]
    let ethicsControls: [EthicsControl]
    let prompts: [BlueprintPrompt]
    let roadmap: [BlueprintRoadmapPhase]

    nonisolated static var demo: PlatformBlueprintSeed {
        let shared = [
            "Identity and role-based access",
            "Design system",
            "Analytics events",
            "Feature flags",
            "Agent workflow audit",
            "Support escalation"
        ]

        func kpi(_ domain: String, _ measures: [String], _ purpose: String) -> PerformanceKPIGroup {
            PerformanceKPIGroup(id: UUID(), domain: domain, measures: measures, purpose: purpose)
        }

        return PlatformBlueprintSeed(
            portfolioApps: [
                PortfolioAppProfile(
                    id: UUID(),
                    name: "AgedCare Monitor",
                    category: .medical,
                    role: "Care monitoring, alerts, and observation workflows.",
                    targetUsers: ["nurses", "care managers", "aged-care operators"],
                    sharedCapabilities: shared
                ),
                PortfolioAppProfile(
                    id: UUID(),
                    name: "CareLens Aged+",
                    category: .medical,
                    role: "Dementia care companion and caregiver support.",
                    targetUsers: ["carers", "families", "clinicians"],
                    sharedCapabilities: shared
                ),
                PortfolioAppProfile(
                    id: UUID(),
                    name: "PeaceLens",
                    category: .education,
                    role: "Learning, structured content, and guided educational experiences.",
                    targetUsers: ["students", "educators", "peace researchers"],
                    sharedCapabilities: shared
                ),
                PortfolioAppProfile(
                    id: UUID(),
                    name: "Psychosocial Analytics",
                    category: .medical,
                    role: "Wellbeing analytics, psychosocial trend insights, and reporting.",
                    targetUsers: ["psychologists", "case managers", "program leads"],
                    sharedCapabilities: shared
                ),
                PortfolioAppProfile(
                    id: UUID(),
                    name: "TruthLens Global",
                    category: .news,
                    role: "Content verification, trust workflows, and evidence-linked outputs.",
                    targetUsers: ["political scientists", "journalists", "public-interest teams"],
                    sharedCapabilities: shared
                ),
                PortfolioAppProfile(
                    id: UUID(),
                    name: "WCS-Tatto",
                    category: .lifestyle,
                    role: "Creative and lifestyle engagement product.",
                    targetUsers: ["creators", "community users", "lifestyle audiences"],
                    sharedCapabilities: shared
                ),
                PortfolioAppProfile(
                    id: UUID(),
                    name: "WCSLIB",
                    category: .education,
                    role: "Library, content repository, and learner progress tracking.",
                    targetUsers: ["learners", "teachers", "program operators"],
                    sharedCapabilities: shared
                )
            ],
            postLaunchProfiles: [
                PostLaunchAppPerformanceProfile(
                    id: UUID(),
                    appName: "AgedCare Monitor",
                    category: .medical,
                    priceAUD: "Free",
                    publicStatus: "Live in AU/US/GB",
                    visibleRatingCount: 0,
                    productMandate: "Lowest-friction entry product in the aged-care line, optimized for adoption, routine care monitoring, and pathway creation into premium WCS services.",
                    northStarGoal: "Weekly active caregivers completing recurring monitoring tasks.",
                    kpiGroups: [
                        kpi("Acquisition", ["App Store page views", "install conversion rate", "source channel mix"], "Track reach and channel quality for the free entry product."),
                        kpi("Activation", ["onboarding completion", "first care record created", "first daily log completed"], "Confirm users reach value in the first session."),
                        kpi("Engagement", ["weekly active users", "logs per care record", "reminders completed"], "Measure caregiver habit formation."),
                        kpi("Quality and trust", ["crash-free sessions", "sync success", "support tickets per 100 users"], "Protect confidence in health-adjacent monitoring.")
                    ],
                    instrumentationEvents: ["install source", "onboarding step", "care profile created", "daily monitoring action", "reminder completed", "export shared", "feature abandoned"],
                    appStoreActions: ["Trigger ratings after successful recurring task completion", "Route unhappy users to support first", "Refresh screenshots around quick daily check-ins"],
                    uxWatchpoints: ["time to first useful action", "readability for stressed caregivers", "reminder usability", "taps to complete daily check-in"],
                    supportActions: ["Lightweight in-app help center", "templates for onboarding and sync issues", "sensitive health-adjacent escalation routing"],
                    retentionActions: ["morning and evening care rituals", "weekly summaries", "caregiver streaks where appropriate", "day-0 care profile cohort tracking"],
                    releaseCadence: "Monthly release train with emergency hotfix capability.",
                    roadmapWaves: ["Wave 1: onboarding optimization and review generation", "Wave 2: caregiver summaries and sharing", "Wave 3: integrations with WCS aged-care products"],
                    monthlyReviewQuestions: ["Are day-0 profile creators retained better?", "Which step blocks the first daily log?", "Are review prompts reaching successful users only?"]
                ),
                PostLaunchAppPerformanceProfile(
                    id: UUID(),
                    appName: "CareLens Aged+",
                    category: .medical,
                    priceAUD: "12.99",
                    publicStatus: "Live in AU/US/GB",
                    visibleRatingCount: 0,
                    productMandate: "Premium care workflow product with stronger activation, trust, support, and conversion requirements than the free monitoring app.",
                    northStarGoal: "Paid users completing first care assessment or actionable report within one day.",
                    kpiGroups: [
                        kpi("Commerce", ["page view to purchase conversion", "refund rate", "country-wise revenue", "paywall abandonment"], "Link pricing to clear workflow value."),
                        kpi("Activation", ["first care plan setup", "first assessment completed", "first report exported"], "Measure paid time-to-value."),
                        kpi("Engagement", ["weekly active care managers", "sessions per user", "report generation frequency"], "Confirm the app becomes a recurring care tool."),
                        kpi("Trust and quality", ["crash-free rate", "premium support response time", "permissions acceptance"], "Support premium expectations.")
                    ],
                    instrumentationEvents: ["product page viewed", "purchase completed", "care plan created", "assessment completed", "report exported", "support started", "refund detected"],
                    appStoreActions: ["Capture testimonials", "Prompt ratings after successful report completion", "Use screenshots that communicate premium workflow value"],
                    uxWatchpoints: ["install-to-first-assessment time", "setup complexity", "permission confusion", "first actionable insight clarity"],
                    supportActions: ["premium support posture", "clear release notes", "billing confusion resolution", "proactive customer success follow-up"],
                    retentionActions: ["reusable templates", "longitudinal reports", "recurring summaries", "family or staff collaboration"],
                    releaseCadence: "Quarterly major releases with monthly minor improvements.",
                    roadmapWaves: ["Wave 1: report-completion rating prompts", "Wave 2: longitudinal care templates", "Wave 3: cross-sell into Psychosocial Analytics and WCSLIB"],
                    monthlyReviewQuestions: ["Are buyers reaching first value within one day?", "Are refunds clustered by device, version, or country?", "Which paid features are underused?", "Which support issues reveal broken expectations?"]
                ),
                PostLaunchAppPerformanceProfile(
                    id: UUID(),
                    appName: "PeaceLens",
                    category: .education,
                    priceAUD: "5.99",
                    publicStatus: "Live in AU/US/GB",
                    visibleRatingCount: 0,
                    productMandate: "Educational engagement product where completion, repeat usage, and institutional usefulness matter as much as direct consumer sales.",
                    northStarGoal: "Learners reaching a second and third guided learning milestone.",
                    kpiGroups: [
                        kpi("Acquisition", ["product page views", "school referral installs", "region mix"], "Measure educational market entry."),
                        kpi("Activation", ["first lesson started", "first lesson completed", "account created"], "Track early learning progress."),
                        kpi("Engagement", ["lessons per week", "completion rates", "repeat opens after day 7"], "Measure durable education use."),
                        kpi("Advocacy", ["teacher recommendations", "school pilot renewals", "ratings count growth"], "Capture institutional trust.")
                    ],
                    instrumentationEvents: ["lesson started", "lesson completed", "account created", "offline session succeeded", "certificate earned", "educator pack opened"],
                    appStoreActions: ["Frame screenshots around learning pathways", "Use pilot proof points", "Prompt after course or milestone completion"],
                    uxWatchpoints: ["lesson drop-off", "media load time", "offline session success", "pathway clarity"],
                    supportActions: ["educator FAQ", "content issue intake", "school pilot support templates"],
                    retentionActions: ["guided pathways", "certificate completion", "educator packs", "class discussion prompts"],
                    releaseCadence: "Monthly content updates and quarterly product feature releases.",
                    roadmapWaves: ["Wave 1: clearer lesson pathway onboarding", "Wave 2: certificate and educator packs", "Wave 3: annual curriculum refresh workflow"],
                    monthlyReviewQuestions: ["Where do learners stop before milestone two?", "Which content types have the strongest completion?", "Are teacher referrals producing retained users?"]
                ),
                PostLaunchAppPerformanceProfile(
                    id: UUID(),
                    appName: "Psychosocial Analytics",
                    category: .medical,
                    priceAUD: "24.99",
                    publicStatus: "Live in AU/US/GB",
                    visibleRatingCount: 0,
                    productMandate: "Premium analytics product where perceived authority, stability, reporting depth, and confidence-building UX drive retention and revenue.",
                    northStarGoal: "Expert users generating recurring dashboard reviews and exported reports.",
                    kpiGroups: [
                        kpi("Commerce", ["conversion rate", "refund rate", "region-wise ARPU", "pricing sensitivity"], "Evaluate premium analytics packaging."),
                        kpi("Activation", ["first dataset entered", "first dashboard loaded", "first report exported"], "Measure expert onboarding success."),
                        kpi("Engagement", ["dashboards viewed per week", "filters used", "report sharing frequency"], "Confirm repeated analytical value."),
                        kpi("Reliability and trust", ["crash-free sessions", "query response time", "failed export rate", "documentation usage"], "Protect confidence in expert outputs.")
                    ],
                    instrumentationEvents: ["dataset entered", "dashboard loaded", "filter applied", "report exported", "example dataset opened", "glossary viewed", "query failed"],
                    appStoreActions: ["Explain premium analytics value in screenshots", "Collect expert testimonials", "Prompt ratings after successful export"],
                    uxWatchpoints: ["time to first dashboard", "abandoned analysis flows", "narrow feature use", "plain-language explanation clarity"],
                    supportActions: ["guided onboarding", "terminology glossaries", "example datasets", "report-type support tagging"],
                    retentionActions: ["monthly outcomes analysis ritual", "multidisciplinary meeting reports", "care-team reporting", "silent churn alerts for falling exports"],
                    releaseCadence: "Monthly quality releases with quarterly analytics capability reviews.",
                    roadmapWaves: ["Wave 1: reporting templates", "Wave 2: comparative trend views", "Wave 3: layered plain-language explanations"],
                    monthlyReviewQuestions: ["Are experts exporting the first report?", "Which report types drive support tickets?", "Are exports or dashboard opens declining silently?"]
                ),
                PostLaunchAppPerformanceProfile(
                    id: UUID(),
                    appName: "TruthLens Global",
                    category: .news,
                    priceAUD: "14.99",
                    publicStatus: "Live in AU/US/GB",
                    visibleRatingCount: 0,
                    productMandate: "Privacy-first civic verification and trust product for political claims, election messages, speeches, and public content.",
                    northStarGoal: "Trusted users completing explainable claim scans and inspecting source credibility during civic information cycles.",
                    kpiGroups: [
                        kpi("Acquisition", ["page views", "install conversion", "referral traffic from campaigns or media"], "Track civic market reach."),
                        kpi("Activation", ["first claim scan", "first alert followed", "first saved report"], "Measure first verification value."),
                        kpi("Engagement", ["scans per user", "session frequency during news cycles", "alert open rate"], "Monitor recurring verification habits."),
                        kpi("Trust and reliability", ["explanation expand rate", "source click-through", "dispute submissions", "verdict latency"], "Protect credibility and challenge workflows.")
                    ],
                    instrumentationEvents: ["claim scanned", "explanation expanded", "source clicked", "verdict disputed", "watchlist saved", "alert opened", "scan failed"],
                    appStoreActions: ["Seek authentic feedback from professional early users", "Avoid aggressive broad prompting", "Show explainable verdicts and source indicators"],
                    uxWatchpoints: ["verdict logic comprehension", "source inspection rate", "latency during election windows", "offline and audit output reliability"],
                    supportActions: ["transparent challenge process", "rapid triage during civic events", "plain-language verdict documentation"],
                    retentionActions: ["saved watchlists", "recurring alerts", "trusted briefings", "professional workflow embedding"],
                    releaseCadence: "Structured retrospective after every major news cycle or election.",
                    roadmapWaves: ["Wave 1: dispute and challenge workflow", "Wave 2: trusted watchlists and briefings", "Wave 3: election-event reliability retrospectives"],
                    monthlyReviewQuestions: ["Are users inspecting evidence behind verdicts?", "Are disputes clustered by topic?", "Did latency stay acceptable during civic peaks?"]
                ),
                PostLaunchAppPerformanceProfile(
                    id: UUID(),
                    appName: "WCS-Tatto",
                    category: .lifestyle,
                    priceAUD: "4.99",
                    publicStatus: "Live in AU/US/GB",
                    visibleRatingCount: 0,
                    productMandate: "Creative engagement product where emotional resonance, completion loops, saved designs, and sharing behavior drive growth.",
                    northStarGoal: "Users completing, saving, and sharing satisfying creative designs.",
                    kpiGroups: [
                        kpi("Acquisition", ["product page views", "install conversion", "region mix"], "Measure creative product discovery."),
                        kpi("Activation", ["first design started", "first design saved", "first export or share"], "Track first delight."),
                        kpi("Engagement", ["creative sessions per week", "average session time", "design revisions per user"], "Measure repeat creativity."),
                        kpi("Quality and advocacy", ["render success", "media export success", "crash-free sessions", "social shares"], "Protect creative output and referral loops.")
                    ],
                    instrumentationEvents: ["design started", "style selected", "design saved", "revision made", "export completed", "share tapped", "render failed"],
                    appStoreActions: ["Prompt after successful save or share", "Refresh screenshots with real creative outputs", "Tie ratings to completed design moments"],
                    uxWatchpoints: ["prompt clarity", "creative flow interruptions", "save failures", "time to first satisfying output"],
                    supportActions: ["creative FAQ", "export troubleshooting", "template request tracking"],
                    retentionActions: ["collections", "seasonal themes", "creative challenges", "unfinished draft reminders"],
                    releaseCadence: "Monthly content drops with quarterly UX improvements.",
                    roadmapWaves: ["Wave 1: first-output speed", "Wave 2: seasonal templates and collections", "Wave 3: cross-linking with WCS creative or educational products"],
                    monthlyReviewQuestions: ["Do users reach a saved design quickly?", "Which styles drive repeat sessions?", "Are export failures blocking reviews?"]
                ),
                PostLaunchAppPerformanceProfile(
                    id: UUID(),
                    appName: "WCSLIB",
                    category: .education,
                    priceAUD: "Not fully visible",
                    publicStatus: "Live in AU/US/GB",
                    visibleRatingCount: 0,
                    productMandate: "Portfolio knowledge hub and cross-product gateway focused on content discovery, completion, and assisted conversion.",
                    northStarGoal: "Users completing guided content and discovering relevant adjacent WCS resources.",
                    kpiGroups: [
                        kpi("Acquisition", ["installs", "page-view conversion", "search keyword performance"], "Track education hub discovery."),
                        kpi("Activation", ["account creation", "first article opened", "first module completed"], "Measure first learning value."),
                        kpi("Engagement", ["sessions per week", "content completion depth", "bookmarks", "search usage"], "Track content habit formation."),
                        kpi("Portfolio contribution", ["click-through to other WCS apps", "assisted conversions", "bundle uptake"], "Measure ecosystem gateway value.")
                    ],
                    instrumentationEvents: ["module opened", "module completed", "search performed", "bookmark saved", "recommendation clicked", "cross-app link tapped", "content load failed"],
                    appStoreActions: ["Position as the WCS knowledge hub", "Prompt ratings after module completion", "Use screenshots showing discovery and progress"],
                    uxWatchpoints: ["search behavior", "module drop-off", "completion by content type", "adjacent resource discovery"],
                    supportActions: ["editorial workflow", "content QA", "metadata standards", "tagging governance"],
                    retentionActions: ["collections", "guided learning paths", "saved reading", "role-based pathways", "cross-app recommendations"],
                    releaseCadence: "Editorial updates on a managed calendar with quarterly discovery improvements.",
                    roadmapWaves: ["Wave 1: metadata and tagging governance", "Wave 2: guided learning paths", "Wave 3: cross-product recommendations and bundles"],
                    monthlyReviewQuestions: ["Can users find relevant content quickly?", "Which modules create cross-app interest?", "Where does completion drop by role?"]
                )
            ],
            postLaunchScorecardSignals: [
                "new installs",
                "Store conversion rate",
                "day-1, day-7, and day-30 retention",
                "average rating and rating count",
                "crash-free users and sessions",
                "support tickets per 100 active users",
                "core value event completion rate"
            ],
            postLaunchEventTaxonomy: [
                EventTaxonomyGroup(id: UUID(), group: "Acquisition", exampleEvents: ["app_open_first_time", "campaign_attribution_received"], purpose: "Tracks market entry and channel quality."),
                EventTaxonomyGroup(id: UUID(), group: "Activation", exampleEvents: ["onboarding_completed", "first_core_action_completed"], purpose: "Measures time-to-value."),
                EventTaxonomyGroup(id: UUID(), group: "Engagement", exampleEvents: ["session_started", "feature_used", "content_completed"], purpose: "Monitors recurring value."),
                EventTaxonomyGroup(id: UUID(), group: "Monetization", exampleEvents: ["purchase_completed", "restore_purchase", "refund_detected"], purpose: "Evaluates pricing and packaging performance."),
                EventTaxonomyGroup(id: UUID(), group: "Quality", exampleEvents: ["crash_detected", "sync_failed", "api_timeout"], purpose: "Supports maintenance discipline."),
                EventTaxonomyGroup(id: UUID(), group: "Support", exampleEvents: ["help_article_opened", "support_contact_started"], purpose: "Reveals friction and support load."),
                EventTaxonomyGroup(id: UUID(), group: "Trust", exampleEvents: ["privacy_settings_opened", "explanation_viewed", "source_clicked"], purpose: "Protects health, education, and civic credibility.")
            ],
            supportServiceLevels: [
                SupportServiceLevel(id: UUID(), issueType: "Critical outage", targetResponse: "Same day response"),
                SupportServiceLevel(id: UUID(), issueType: "Paid app workflow blocker", targetResponse: "Within one business day"),
                SupportServiceLevel(id: UUID(), issueType: "Non-critical bug", targetResponse: "Within two business days"),
                SupportServiceLevel(id: UUID(), issueType: "Content or education question", targetResponse: "Within three business days")
            ],
            portfolioOperatingCadence: [
                PortfolioOperatingCadence(id: UUID(), period: "Month 1 to 2", focus: "Telemetry completeness, onboarding funnels, crash reduction, and App Store listing clarity.", outcomes: ["reliable observation", "core funnels instrumented", "first support taxonomy"]),
                PortfolioOperatingCadence(id: UUID(), period: "Month 3 to 4", focus: "Ratings generation, support pattern analysis, and first retention interventions.", outcomes: ["review prompts tuned", "support themes linked to roadmap", "saved progress and reminders improved"]),
                PortfolioOperatingCadence(id: UUID(), period: "Month 5 to 6", focus: "Segmentation, pricing and package evaluation, and cross-product pathways.", outcomes: ["paid app pricing review", "cohort segmentation", "ecosystem referrals measured"]),
                PortfolioOperatingCadence(id: UUID(), period: "Month 7 to 9", focus: "Feature consolidation and expansion of successful engagement loops.", outcomes: ["low-value complexity reduced", "high-performing loops scaled", "roadmap rationalized"]),
                PortfolioOperatingCadence(id: UUID(), period: "Month 10 to 12", focus: "Strategic repositioning, bundling, enterprise packaging, and next annual roadmap reset.", outcomes: ["bundle plan", "institutional packaging options", "annual roadmap reset"])
            ],
            processTranslations: [
                ProcessGroupTranslation(id: UUID(), bookTheme: "Digital Product Management Overview", wcsTranslation: "Define platform vision and app taxonomy.", deliveryOutput: "Portfolio charter"),
                ProcessGroupTranslation(id: UUID(), bookTheme: "Leading Product Development", wcsTranslation: "Discovery, backlog design, and technical planning.", deliveryOutput: "Epics and architecture decision records"),
                ProcessGroupTranslation(id: UUID(), bookTheme: "Delivering Digital Products", wcsTranslation: "Agile implementation and release train design.", deliveryOutput: "Sprint plans and definition of done"),
                ProcessGroupTranslation(id: UUID(), bookTheme: "Crafting the Marketing Strategy", wcsTranslation: "App Store optimization, launch copy, and audience targeting.", deliveryOutput: "Launch campaign kit"),
                ProcessGroupTranslation(id: UUID(), bookTheme: "Managing Sales Channels and Launching Products", wcsTranslation: "App Store release, web funnel, pilot rollout, and launch roadmap.", deliveryOutput: "Launch roadmap"),
                ProcessGroupTranslation(id: UUID(), bookTheme: "Engaging Customers and Seamless Experience", wcsTranslation: "Onboarding, support touchpoints, and personalization.", deliveryOutput: "Journey maps and onboarding flows"),
                ProcessGroupTranslation(id: UUID(), bookTheme: "Supporting and Maintaining Products", wcsTranslation: "SLAs, incident runbooks, patching, and support review.", deliveryOutput: "Support and maintenance handbook"),
                ProcessGroupTranslation(id: UUID(), bookTheme: "Leveraging Product Analytics", wcsTranslation: "Event pipeline, dashboards, customer insights, and feature adoption.", deliveryOutput: "Analytics schema and KPI dashboards"),
                ProcessGroupTranslation(id: UUID(), bookTheme: "Building and Scaling the Operating Model", wcsTranslation: "Cross-functional governance, shared services, and process scaling.", deliveryOutput: "Portfolio ops framework"),
                ProcessGroupTranslation(id: UUID(), bookTheme: "Ethics and Continuous Improvement", wcsTranslation: "Consent, privacy, fairness, auditability, retrospectives, and innovation backlog.", deliveryOutput: "Ethics policy and continuous improvement backlog")
            ],
            launchPlaybook: [
                LaunchPlaybookPhase(id: UUID(), phase: "Pre-launch", goal: "Prepare each release with evidence, instrumentation, and support readiness.", actions: ["define launch goals and risk thresholds", "prepare product brief, value proposition, App Store assets, FAQ, and support scripts", "train support and stakeholders on limitations and escalation paths", "validate analytics before day-one launch"]),
                LaunchPlaybookPhase(id: UUID(), phase: "Launch", goal: "Coordinate App Store, owned-channel, pilot, community, and sector outreach.", actions: ["release through App Store and owned channels", "personalize messaging by audience segment", "monitor crashes, sign-in failures, API errors, and onboarding drop-off", "keep support and engineering on the same live dashboard"]),
                LaunchPlaybookPhase(id: UUID(), phase: "Post-launch", goal: "Turn early market evidence into reusable product and operating improvements.", actions: ["review goals against actual performance", "identify channels and product moments that drove adoption", "update WCS launch playbooks", "monitor competitors, feedback, ratings, and support themes"])
            ],
            repositoryLayout: [
                RepositoryLayoutGroup(id: UUID(), path: "apps/", purpose: "Branded iOS products on the shared WCS foundation.", children: ["AgedCareMonitor-iOS", "CareLensAged-iOS", "PeaceLens-iOS", "PsychosocialAnalytics-iOS", "TruthLensGlobal-iOS", "WCSTatto-iOS", "WCSLIB-iOS"]),
                RepositoryLayoutGroup(id: UUID(), path: "packages/", purpose: "Reusable platform modules shared across app shells.", children: ["WCSDesignSystem", "WCSAuth", "WCSNetworking", "WCSAnalytics", "WCSFeatureFlags", "WCSAI", "WCSDomain"]),
                RepositoryLayoutGroup(id: UUID(), path: "backend/", purpose: "Tenant-aware APIs, event ingestion, campaigns, workflows, and admin operations.", children: ["api-gateway", "event-worker", "notification-worker", "analytics-pipeline", "admin"]),
                RepositoryLayoutGroup(id: UUID(), path: "infra/", purpose: "Release automation, provisioning, deployment, and rollback infrastructure.", children: ["github-actions", "fastlane", "terraform"])
            ],
            monitoringStack: [
                MonitoringStackItem(id: UUID(), need: "Client crashes", toolingPattern: "Sentry for iOS", purpose: "Detect release-linked crashes and protect user trust."),
                MonitoringStackItem(id: UUID(), need: "API errors and traces", toolingPattern: "Datadog APM or New Relic", purpose: "Track backend latency, exceptions, and service health."),
                MonitoringStackItem(id: UUID(), need: "Uptime", toolingPattern: "Status page and external synthetic checks", purpose: "Catch outages before support tickets spike."),
                MonitoringStackItem(id: UUID(), need: "Product analytics", toolingPattern: "PostHog, Mixpanel, or Amplitude", purpose: "Measure acquisition, activation, retention, and feature adoption."),
                MonitoringStackItem(id: UUID(), need: "Warehouse", toolingPattern: "BigQuery, Snowflake, or Postgres analytics replica", purpose: "Support cohort, revenue, and portfolio-level analysis."),
                MonitoringStackItem(id: UUID(), need: "Alerts", toolingPattern: "Slack, PagerDuty, or Opsgenie", purpose: "Route incident signals to accountable responders.")
            ],
            deploymentRules: [
                ContinuousDeploymentRule(id: UUID(), rule: "Every non-trivial feature ships behind a feature flag.", reason: "Allows phased rollout, rollback, and cohort-based learning."),
                ContinuousDeploymentRule(id: UUID(), rule: "Use phased release for all production launches.", reason: "Limits blast radius while monitoring crash-free sessions, activation, support, and ratings."),
                ContinuousDeploymentRule(id: UUID(), rule: "Maintain rollback paths for iOS versions, API deployments, schema migrations, and remote config.", reason: "Keeps launch governance practical when production signals deteriorate."),
                ContinuousDeploymentRule(id: UUID(), rule: "Require engineering, product, design, analytics, support, and privacy sign-off before major launch.", reason: "Connects delivery quality with operating readiness.")
            ],
            portfolioReviewLoops: [
                PortfolioReviewLoop(id: UUID(), cadence: "Weekly dashboard", focus: "Standardize post-launch comparison across every live WCS app.", decisions: ["new installs", "Store conversion rate", "day-1, day-7, and day-30 retention", "average rating and rating count", "crash-free users and sessions", "support tickets per 100 active users", "core value event completion rate"]),
                PortfolioReviewLoop(id: UUID(), cadence: "Monthly business review", focus: "Compare product families rather than treating each app as an isolated product.", decisions: ["separate acquisition, activation, engagement, and monetization problems", "connect support patterns to roadmap changes", "review ratings and App Store conversion together"]),
                PortfolioReviewLoop(id: UUID(), cadence: "Quarterly roadmap review", focus: "Decide whether each product should accelerate, stabilize, reposition, bundle, or simplify.", decisions: ["use analytics evidence", "use support evidence", "use ratings and review evidence", "use release outcome evidence"])
            ],
            telemetryLayers: [
                TelemetryLayerSpec(id: UUID(), layer: "App Store Connect metrics", captures: ["acquisition", "conversion", "retention", "crashes", "ratings"], managementUse: "Validates market-facing performance and listing quality."),
                TelemetryLayerSpec(id: UUID(), layer: "In-app analytics", captures: ["event behavior", "feature funnels", "activation", "core value completion"], managementUse: "Finds where users reach or miss first value."),
                TelemetryLayerSpec(id: UUID(), layer: "Crash and performance telemetry", captures: ["latency", "memory pressure", "launch time", "failure points"], managementUse: "Protects reliability before growth and review prompts."),
                TelemetryLayerSpec(id: UUID(), layer: "Support tagging", captures: ["product version", "device", "OS", "issue type", "severity", "root cause"], managementUse: "Connects support operations to releases and roadmap decisions.")
            ],
            reviewOperations: [
                ReviewOperationsSpec(id: UUID(), workflow: "Ratings generation", practices: ["trigger prompts after successful task completion", "suppress prompts after recent errors", "ask highly engaged users first", "route unhappy users to support before public review"]),
                ReviewOperationsSpec(id: UUID(), workflow: "Review response triage", practices: ["classify bugs", "classify UX confusion", "classify trust concerns", "classify pricing friction", "classify missing features", "classify support requests"])
            ],
            supportTaxonomyFields: [
                SupportTaxonomyField(id: UUID(), field: "App name", purpose: "Groups operational issues by product line."),
                SupportTaxonomyField(id: UUID(), field: "Version", purpose: "Links support spikes to release changes."),
                SupportTaxonomyField(id: UUID(), field: "Device/OS", purpose: "Finds platform-specific failures."),
                SupportTaxonomyField(id: UUID(), field: "Issue type", purpose: "Separates billing, UX, content, reliability, and trust problems."),
                SupportTaxonomyField(id: UUID(), field: "Severity", purpose: "Drives response time and escalation."),
                SupportTaxonomyField(id: UUID(), field: "Resolution time", purpose: "Measures SLA performance."),
                SupportTaxonomyField(id: UUID(), field: "Root cause", purpose: "Turns support tickets into product learning.")
            ],
            riskEthicsFocusAreas: [
                RiskEthicsFocusArea(id: UUID(), productGroup: "Health apps", controls: ["privacy controls", "explicit consent", "sensitive-data safeguards", "human review for high-impact workflows"]),
                RiskEthicsFocusArea(id: UUID(), productGroup: "Civic/news app", controls: ["trust audits", "challenge workflows", "governance reviews", "explanation quality checks"]),
                RiskEthicsFocusArea(id: UUID(), productGroup: "Education and lifestyle apps", controls: ["content integrity", "age appropriateness where relevant", "clear claims", "accessibility checks"])
            ],
            reportAssemblyPlan: [
                ReportAssemblyItem(id: UUID(), section: "Portfolio overview", contents: ["live app inventory", "category and pricing table", "public status", "visible ratings baseline"]),
                ReportAssemblyItem(id: UUID(), section: "App-specific chapters", contents: ["product mandate", "north-star goal", "KPI dictionary", "instrumentation plan", "support playbook", "retention strategy", "release cadence", "strategic roadmap"]),
                ReportAssemblyItem(id: UUID(), section: "Evidence appendices", contents: ["screenshots", "KPI templates", "release logs", "review excerpts", "support taxonomies", "cohort charts", "SOP appendices"]),
                ReportAssemblyItem(id: UUID(), section: "Portfolio governance", contents: ["weekly scorecard", "monthly business review", "quarterly roadmap review", "risk and ethics controls", "12-month cadence"])
            ],
            appSupplements: [
                AppSupplementSpec(id: UUID(), appName: "AgedCare Monitor", supplementOutputs: ["KPI dictionary", "care monitoring funnel", "caregiver cohort dashboard", "health-adjacent support workflow", "ethics controls"]),
                AppSupplementSpec(id: UUID(), appName: "CareLens Aged+", supplementOutputs: ["paid conversion funnel", "first assessment completion dashboard", "premium support workflow", "refund review checklist", "care-report release checklist"]),
                AppSupplementSpec(id: UUID(), appName: "PeaceLens", supplementOutputs: ["lesson progression dashboard", "educator pilot workflow", "content calendar", "completion cohort report", "education support taxonomy"]),
                AppSupplementSpec(id: UUID(), appName: "Psychosocial Analytics", supplementOutputs: ["expert onboarding funnel", "dashboard and export reliability report", "glossary support workflow", "premium analytics roadmap checklist"]),
                AppSupplementSpec(id: UUID(), appName: "TruthLens Global", supplementOutputs: ["claim-scan funnel", "source-click trust dashboard", "challenge workflow", "civic event retrospective checklist", "governance audit"]),
                AppSupplementSpec(id: UUID(), appName: "WCS-Tatto", supplementOutputs: ["creative completion funnel", "save and export quality report", "template release calendar", "seasonal retention plan"]),
                AppSupplementSpec(id: UUID(), appName: "WCSLIB", supplementOutputs: ["content discovery funnel", "module completion dashboard", "metadata governance workflow", "cross-app recommendation report"])
            ],
            implementationStarterArtifacts: [
                ImplementationStarterArtifact(id: UUID(), title: "SwiftUI app shell", layer: "iOS client", purpose: "Bootstraps shared state, restores authentication, checks onboarding, and starts analytics.", excerpt: ["@main WCSApp", "RootView().environmentObject(appState)", "appState.bootstrap()", "track app_bootstrap_started and app_bootstrap_completed"]),
                ImplementationStarterArtifact(id: UUID(), title: "Root routing", layer: "iOS client", purpose: "Routes users through onboarding, sign-in, or the main tab shell from one state source.", excerpt: ["if onboarding is incomplete show OnboardingFlowView", "else if unauthenticated show SignInView", "else show MainTabView"]),
                ImplementationStarterArtifact(id: UUID(), title: "Agent task protocol", layer: "Agent workflows", purpose: "Standardizes safe agent execution with context, permissions, feature flags, results, and fallback failure output.", excerpt: ["AgentTask.name", "run(context:) async throws", "AgentContext userId, orgId, permissions, featureFlags", "AgentResult summary, actions, confidence"]),
                ImplementationStarterArtifact(id: UUID(), title: "Fastify backend starter", layer: "Backend", purpose: "Defines the first multi-tenant platform endpoints for health checks, event ingestion, and queued agent workflows.", excerpt: ["GET /health returns ok", "POST /v1/events returns ingested count", "POST /v1/agent/run returns workflowId, queued status, and intent"]),
                ImplementationStarterArtifact(id: UUID(), title: "Database starter schema", layer: "Data", purpose: "Creates the foundational organization, user, app event, and event-time index tables.", excerpt: ["organizations id, name, created_at", "users org_id, email, role", "app_events org_id, user_id, app_name, event_name, properties", "index app_name, event_name, created_at"]),
                ImplementationStarterArtifact(id: UUID(), title: "Event payload starter", layer: "Analytics", purpose: "Provides a typed event shape for portfolio-wide analytics ingestion and cohort reporting.", excerpt: ["app_name: CareLens Aged+", "event_name: care_note_created", "user_id and org_id UUIDs", "properties include patient_id, source, ai_assisted, duration_seconds"])
            ],
            scalabilityPrinciples: [
                ScalabilityPrinciple(id: UUID(), principle: "Keep APIs stateless and horizontally scalable.", operationalImpact: "Allows traffic spikes across the live portfolio without reworking business logic."),
                ScalabilityPrinciple(id: UUID(), principle: "Separate transactional workloads from analytics-heavy workloads.", operationalImpact: "Protects care, education, civic, and creative workflows from reporting load."),
                ScalabilityPrinciple(id: UUID(), principle: "Queue expensive jobs such as campaign sends, report generation, and AI enrichment.", operationalImpact: "Keeps interactive app experiences responsive while background work scales safely."),
                ScalabilityPrinciple(id: UUID(), principle: "Use modular packages on iOS.", operationalImpact: "Prevents the portfolio from collapsing into one oversized codebase."),
                ScalabilityPrinciple(id: UUID(), principle: "Centralize observability and release operations.", operationalImpact: "Makes support, reliability, and rollout quality comparable across all branded apps.")
            ],
            maintenancePractices: [
                MaintenancePractice(id: UUID(), practice: "Define SLAs and severity levels for product incidents.", evidence: "Support response targets and escalation paths are reviewable before release."),
                MaintenancePractice(id: UUID(), practice: "Maintain support runbooks, rollback guides, and release retrospectives.", evidence: "Every release has an operational record and a recovery path."),
                MaintenancePractice(id: UUID(), practice: "Schedule dependency updates, security patching, and quarterly architecture reviews.", evidence: "Platform quality is managed as a recurring product responsibility."),
                MaintenancePractice(id: UUID(), practice: "Track technical debt explicitly in the roadmap.", evidence: "Engineering quality does not disappear behind feature expansion.")
            ],
            automationSnippets: [
                AutomationSnippet(id: UUID(), title: "GitHub Actions iOS CI", tool: "GitHub Actions", purpose: "Validate pull requests, build simulator tests, and archive releases on main.", excerpt: ["checkout source", "select latest stable Xcode", "install dependencies", "run lint and tests", "archive release candidate"]),
                AutomationSnippet(id: UUID(), title: "Fastlane beta lane", tool: "Fastlane", purpose: "Produce internal TestFlight builds with consistent versioning.", excerpt: ["increment build number", "build app", "upload to TestFlight", "skip waiting for processing where appropriate"]),
                AutomationSnippet(id: UUID(), title: "Fastlane release lane", tool: "Fastlane", purpose: "Capture screenshots, build signed artifacts, upload metadata, and hold for manual release.", excerpt: ["capture screenshots", "build app", "upload to App Store", "submit for review", "disable automatic release"])
            ],
            operatingFunctions: [
                ProductOperatingFunction(id: UUID(), name: "Product leadership", responsibility: "Portfolio strategy, problem framing, and KPI ownership.", artifacts: ["product briefs", "roadmaps", "launch goals"]),
                ProductOperatingFunction(id: UUID(), name: "Product ops", responsibility: "Launch governance, checklists, and cross-team alignment.", artifacts: ["launch readiness packs", "playbooks", "review cadences"]),
                ProductOperatingFunction(id: UUID(), name: "Design", responsibility: "Design system, UX patterns, and accessibility reviews.", artifacts: ["component library", "journey maps", "prototypes"]),
                ProductOperatingFunction(id: UUID(), name: "iOS engineering", responsibility: "SwiftUI app development, release quality, and performance.", artifacts: ["app modules", "tests", "release builds"]),
                ProductOperatingFunction(id: UUID(), name: "Platform engineering", responsibility: "APIs, auth, jobs, telemetry, storage, and integrations.", artifacts: ["services", "schemas", "queues", "dashboards"]),
                ProductOperatingFunction(id: UUID(), name: "Growth and marketing", responsibility: "App Store optimization, campaigns, and lifecycle messaging.", artifacts: ["ASO assets", "campaign plans", "retention sequences"]),
                ProductOperatingFunction(id: UUID(), name: "Support and success", responsibility: "Triage, issue resolution, FAQs, and customer feedback.", artifacts: ["knowledge base", "incident logs", "escalation playbooks"]),
                ProductOperatingFunction(id: UUID(), name: "Data and analytics", responsibility: "Event taxonomy, dashboards, experiments, and insight loops.", artifacts: ["metrics dictionary", "retention reports", "cohorts"])
            ],
            governanceRituals: [
                GovernanceRitual(id: UUID(), cadence: "Weekly", focus: "Portfolio review", outputs: ["roadmap health", "launch readiness", "dependency risks"]),
                GovernanceRitual(id: UUID(), cadence: "Weekly", focus: "Engineering review", outputs: ["build stability", "incidents", "technical debt", "test coverage"]),
                GovernanceRitual(id: UUID(), cadence: "Weekly", focus: "Growth review", outputs: ["acquisition", "activation", "trial conversion", "campaign performance"]),
                GovernanceRitual(id: UUID(), cadence: "Monthly", focus: "Support review", outputs: ["recurring issues", "top tickets", "documentation gaps", "postmortem themes"]),
                GovernanceRitual(id: UUID(), cadence: "Quarterly", focus: "Portfolio review", outputs: ["app rationalization", "resource allocation", "scalability", "innovation bets"])
            ],
            architectureLayers: [
                PlatformArchitectureLayer(id: UUID(), kind: .iosApps, title: "Branded iOS shells", components: ["AgedCare Monitor", "CareLens Aged+", "PeaceLens", "Psychosocial Analytics", "TruthLens Global", "WCS-Tatto", "WCSLIB"], purpose: "Deliver multiple WCS products on one reusable native foundation."),
                PlatformArchitectureLayer(id: UUID(), kind: .sharedPackages, title: "Swift packages", components: ["WCSDesignSystem", "WCSAuth", "WCSNetworking", "WCSAnalytics", "WCSFeatureFlags", "WCSAI", "WCSDomain"], purpose: "Prevent duplicated app code and keep portfolio behavior consistent."),
                PlatformArchitectureLayer(id: UUID(), kind: .apiGateway, title: "API gateway and BFF", components: ["Auth service", "User and org service", "Content service", "Analytics ingestion", "Notification orchestrator", "Agent workflow service", "Admin APIs"], purpose: "Expose tenant-aware business APIs and controlled agent workflows."),
                PlatformArchitectureLayer(id: UUID(), kind: .dataLayer, title: "Data platform", components: ["PostgreSQL or Supabase", "Object storage", "Redis or queue", "Event warehouse", "Audit logs"], purpose: "Separate transactional, analytical, and audit workloads."),
                PlatformArchitectureLayer(id: UUID(), kind: .operations, title: "Ops layer", components: ["CI/CD", "Monitoring", "Feature flags", "A/B testing", "Support console"], purpose: "Connect build automation, release governance, support, and post-launch learning.")
            ],
            technologyChoices: [
                TechnologyChoice(id: UUID(), layer: "iOS client", recommendation: "SwiftUI, async/await, SPM modules, Observation or MVVM+C", purpose: "Reusable native app foundation."),
                TechnologyChoice(id: UUID(), layer: "API layer", recommendation: "Fastify, NestJS, or Vapor", purpose: "Multi-tenant business APIs."),
                TechnologyChoice(id: UUID(), layer: "Database", recommendation: "PostgreSQL or Supabase Postgres", purpose: "Transactional storage."),
                TechnologyChoice(id: UUID(), layer: "Auth", recommendation: "Supabase Auth, Clerk, custom JWT, or Apple-native identity", purpose: "Secure tenant-aware identity."),
                TechnologyChoice(id: UUID(), layer: "Analytics", recommendation: "PostHog, Mixpanel, Amplitude, or warehouse-backed events", purpose: "Product analytics and experiments."),
                TechnologyChoice(id: UUID(), layer: "CI/CD", recommendation: "GitHub Actions, Fastlane, and Xcode Cloud", purpose: "Build, sign, release, and phased rollout.")
            ],
            releaseGates: [
                ReleaseReadinessGate(id: UUID(), title: "Product brief approved", owner: "Product leadership", evidenceRequired: ["problem statement", "target audience", "success metrics"], isComplete: true),
                ReleaseReadinessGate(id: UUID(), title: "Analytics schema validated", owner: "Data and analytics", evidenceRequired: ["event taxonomy", "dashboard checks", "cohort plan"], isComplete: false),
                ReleaseReadinessGate(id: UUID(), title: "Support pack ready", owner: "Support and success", evidenceRequired: ["FAQ", "known limitations", "escalation paths"], isComplete: false),
                ReleaseReadinessGate(id: UUID(), title: "Privacy and ethics review", owner: "Governance", evidenceRequired: ["consent flow", "data handling notes", "human review gates"], isComplete: false),
                ReleaseReadinessGate(id: UUID(), title: "Release candidate tested", owner: "iOS engineering", evidenceRequired: ["unit tests", "UI tests", "crash-free smoke run"], isComplete: true)
            ],
            kpis: [
                ProductKPI(id: UUID(), domain: "Acquisition", measures: ["App Store impressions", "product page conversion", "install rate", "CAC"], purpose: "Measures reach and efficiency."),
                ProductKPI(id: UUID(), domain: "Activation", measures: ["onboarding completion", "account creation", "first key action"], purpose: "Reveals early value realization."),
                ProductKPI(id: UUID(), domain: "Engagement", measures: ["DAU", "WAU", "MAU", "sessions per user"], purpose: "Indicates habit formation."),
                ProductKPI(id: UUID(), domain: "Retention", measures: ["D1", "D7", "D30", "cohort survival", "churn risk"], purpose: "Measures sustained product value."),
                ProductKPI(id: UUID(), domain: "Reliability", measures: ["crash-free users", "API p95 latency", "failed jobs"], purpose: "Protects user trust."),
                ProductKPI(id: UUID(), domain: "Support", measures: ["ticket volume", "first response time", "resolution rate"], purpose: "Reflects operational quality.")
            ],
            dashboards: [
                DashboardSpec(id: UUID(), name: "Executive dashboard", audience: "Leadership", signals: ["portfolio health", "revenue", "retention", "crash-free users", "support load"]),
                DashboardSpec(id: UUID(), name: "Product dashboard", audience: "Product teams", signals: ["activation funnel", "feature adoption", "cohort retention", "experiments"]),
                DashboardSpec(id: UUID(), name: "Growth dashboard", audience: "Growth and marketing", signals: ["acquisition source", "campaign conversion", "lifecycle uplift"]),
                DashboardSpec(id: UUID(), name: "Operations dashboard", audience: "Engineering and ops", signals: ["API latency", "queue depth", "failed jobs", "incident trends"]),
                DashboardSpec(id: UUID(), name: "Support dashboard", audience: "Support", signals: ["top issue categories", "SLA performance", "release-linked ticket spikes"])
            ],
            ethicsControls: [
                EthicsControl(id: UUID(), title: "Privacy by design", appliesTo: "All apps", control: "Capture consent, minimize data, and make data handling transparent."),
                EthicsControl(id: UUID(), title: "Least privilege", appliesTo: "Healthcare and education apps", control: "Restrict data access by role, organization, and explicit purpose."),
                EthicsControl(id: UUID(), title: "Agent audit trail", appliesTo: "AI workflows", control: "Log recommendations, edits, approvals, and high-risk actions."),
                EthicsControl(id: UUID(), title: "Human review gate", appliesTo: "Care, psychosocial, and trust-sensitive workflows", control: "Require human approval before automated high-impact actions."),
                EthicsControl(id: UUID(), title: "Accessible explanations", appliesTo: "All user-facing outputs", control: "Support dynamic type, plain language, and explainable recommendations.")
            ],
            prompts: [
                BlueprintPrompt(id: UUID(), title: "Portfolio scaffold", prompt: "Build a production-grade SwiftUI portfolio foundation for the WCS app family with shared design, auth, networking, analytics, feature flags, AI workflows, domain models, configs, and test targets.", expectedOutput: "Workspace layout, app targets, packages, environments, and tests."),
                BlueprintPrompt(id: UUID(), title: "Healthcare app shell", prompt: "Create a CareLens Aged+ SwiftUI shell with onboarding, sign in, care dashboard, timeline, observations, alerts, AI-assisted notes, offline persistence, accessibility, analytics, and error handling.", expectedOutput: "Feature-complete healthcare MVP scaffold."),
                BlueprintPrompt(id: UUID(), title: "Backend platform", prompt: "Generate a multi-tenant backend with auth, organizations, users, content, event ingestion, notifications, agent workflows, audit logs, admin APIs, migrations, OpenAPI, queues, Docker, and tests.", expectedOutput: "Deployable backend skeleton."),
                BlueprintPrompt(id: UUID(), title: "CI/CD", prompt: "Generate GitHub Actions and Fastlane pipelines for PR checks, signing, TestFlight, App Store release, phased rollout, semantic versioning, changelogs, secret scanning, and rollback.", expectedOutput: "Release automation and governance."),
                BlueprintPrompt(id: UUID(), title: "Analytics system", prompt: "Design typed analytics for acquisition, activation, engagement, retention, monetization, reliability, and support burden.", expectedOutput: "Swift wrappers, payload contracts, KPI dictionary, dashboards, and cohorts."),
                BlueprintPrompt(id: UUID(), title: "Agentic workflow engine", prompt: "Design safe healthcare and education agent orchestration with protocols, task pipelines, audit records, prompt templates, human approvals, fallback states, and activity logs.", expectedOutput: "Governed AI workflow framework.")
            ],
            roadmap: [
                BlueprintRoadmapPhase(id: UUID(), title: "Phase 1: platform foundation", objective: "Define the portfolio charter and stand up shared platform capabilities.", deliverables: ["app taxonomy", "KPI dictionary", "governance model", "design system", "auth", "analytics SDK", "backend skeleton", "admin console foundation"]),
                BlueprintRoadmapPhase(id: UUID(), title: "Phase 2: flagship app release", objective: "Ship one flagship app on the shared platform.", deliverables: ["CareLens Aged+ or AgedCare Monitor MVP", "CI/CD", "analytics", "incident monitoring", "phased rollout", "launch readiness review"]),
                BlueprintRoadmapPhase(id: UUID(), title: "Phase 3: portfolio expansion", objective: "Extend the platform across education, psychosocial, and trust products.", deliverables: ["WCSLIB", "Psychosocial Analytics", "PeaceLens", "portfolio dashboards", "release calendar"]),
                BlueprintRoadmapPhase(id: UUID(), title: "Phase 4: scale and optimize", objective: "Mature retention, experimentation, support automation, and quarterly architecture review.", deliverables: ["retention analysis", "experimentation", "lifecycle campaigns", "support automation", "architecture review"])
            ]
        )
    }
}

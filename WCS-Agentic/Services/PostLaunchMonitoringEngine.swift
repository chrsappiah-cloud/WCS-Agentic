//
//  PostLaunchMonitoringEngine.swift
//  WCS-Agentic
//

import Foundation

struct PostLaunchWeeklySnapshot: Codable, Identifiable, Hashable {
    let id: UUID
    let appName: String
    let weekStart: Date
    let newInstalls: Int
    let storeConversionRate: Double
    let day1Retention: Double
    let day7Retention: Double
    let day30Retention: Double
    let averageRating: Double
    let ratingCount: Int
    let crashFreeUsersRate: Double
    let crashFreeSessionsRate: Double
    let supportTicketsPer100Users: Double
    let coreValueCompletionRate: Double
    let recentErrorCount: Int
    let engagedSessions: Int
    let successfulCoreActions: Int
    let daysSinceLastRatingPrompt: Int

    init(
        id: UUID = UUID(),
        appName: String,
        weekStart: Date = Date(timeIntervalSince1970: 1_812_988_800),
        newInstalls: Int,
        storeConversionRate: Double,
        day1Retention: Double,
        day7Retention: Double,
        day30Retention: Double,
        averageRating: Double,
        ratingCount: Int,
        crashFreeUsersRate: Double,
        crashFreeSessionsRate: Double,
        supportTicketsPer100Users: Double,
        coreValueCompletionRate: Double,
        recentErrorCount: Int,
        engagedSessions: Int,
        successfulCoreActions: Int,
        daysSinceLastRatingPrompt: Int
    ) {
        self.id = id
        self.appName = appName
        self.weekStart = weekStart
        self.newInstalls = newInstalls
        self.storeConversionRate = storeConversionRate
        self.day1Retention = day1Retention
        self.day7Retention = day7Retention
        self.day30Retention = day30Retention
        self.averageRating = averageRating
        self.ratingCount = ratingCount
        self.crashFreeUsersRate = crashFreeUsersRate
        self.crashFreeSessionsRate = crashFreeSessionsRate
        self.supportTicketsPer100Users = supportTicketsPer100Users
        self.coreValueCompletionRate = coreValueCompletionRate
        self.recentErrorCount = recentErrorCount
        self.engagedSessions = engagedSessions
        self.successfulCoreActions = successfulCoreActions
        self.daysSinceLastRatingPrompt = daysSinceLastRatingPrompt
    }
}

struct PortfolioScorecard: Codable, Identifiable, Hashable {
    let id: UUID
    let appCount: Int
    let totalNewInstalls: Int
    let averageStoreConversionRate: Double
    let averageDay30Retention: Double
    let averageRating: Double
    let totalRatingCount: Int
    let averageCrashFreeUsersRate: Double
    let averageSupportTicketsPer100Users: Double
    let averageCoreValueCompletionRate: Double
    let zeroRatingAppNames: [String]
    let riskSummary: String

    init(
        id: UUID = UUID(),
        appCount: Int,
        totalNewInstalls: Int,
        averageStoreConversionRate: Double,
        averageDay30Retention: Double,
        averageRating: Double,
        totalRatingCount: Int,
        averageCrashFreeUsersRate: Double,
        averageSupportTicketsPer100Users: Double,
        averageCoreValueCompletionRate: Double,
        zeroRatingAppNames: [String],
        riskSummary: String
    ) {
        self.id = id
        self.appCount = appCount
        self.totalNewInstalls = totalNewInstalls
        self.averageStoreConversionRate = averageStoreConversionRate
        self.averageDay30Retention = averageDay30Retention
        self.averageRating = averageRating
        self.totalRatingCount = totalRatingCount
        self.averageCrashFreeUsersRate = averageCrashFreeUsersRate
        self.averageSupportTicketsPer100Users = averageSupportTicketsPer100Users
        self.averageCoreValueCompletionRate = averageCoreValueCompletionRate
        self.zeroRatingAppNames = zeroRatingAppNames
        self.riskSummary = riskSummary
    }
}

struct RatingPromptDecision: Codable, Identifiable, Hashable {
    let id: UUID
    let appName: String
    let shouldPrompt: Bool
    let reason: String
    let nextAction: String

    init(id: UUID = UUID(), appName: String, shouldPrompt: Bool, reason: String, nextAction: String) {
        self.id = id
        self.appName = appName
        self.shouldPrompt = shouldPrompt
        self.reason = reason
        self.nextAction = nextAction
    }
}

enum ReviewIssueCategory: String, Codable, CaseIterable {
    case bug = "Bug"
    case uxConfusion = "UX confusion"
    case trustConcern = "Trust concern"
    case pricingFriction = "Pricing friction"
    case missingFeature = "Missing feature"
    case supportRequest = "Support request"
}

struct ReviewTriageResult: Codable, Identifiable, Hashable {
    let id: UUID
    let appName: String
    let category: ReviewIssueCategory
    let severity: MonitoringSeverity
    let route: String
    let roadmapSignal: String

    init(
        id: UUID = UUID(),
        appName: String,
        category: ReviewIssueCategory,
        severity: MonitoringSeverity,
        route: String,
        roadmapSignal: String
    ) {
        self.id = id
        self.appName = appName
        self.category = category
        self.severity = severity
        self.route = route
        self.roadmapSignal = roadmapSignal
    }
}

struct SupportTicketInput: Codable, Identifiable, Hashable {
    let id: UUID
    let appName: String
    let issueType: String
    let severity: MonitoringSeverity
    let appVersion: String
    let deviceOS: String
    let rootCause: String?

    init(
        id: UUID = UUID(),
        appName: String,
        issueType: String,
        severity: MonitoringSeverity,
        appVersion: String,
        deviceOS: String,
        rootCause: String? = nil
    ) {
        self.id = id
        self.appName = appName
        self.issueType = issueType
        self.severity = severity
        self.appVersion = appVersion
        self.deviceOS = deviceOS
        self.rootCause = rootCause
    }
}

struct SupportTriageResult: Codable, Identifiable, Hashable {
    let id: UUID
    let appName: String
    let issueType: String
    let targetResponse: String
    let escalation: String
    let tags: [String]

    init(
        id: UUID = UUID(),
        appName: String,
        issueType: String,
        targetResponse: String,
        escalation: String,
        tags: [String]
    ) {
        self.id = id
        self.appName = appName
        self.issueType = issueType
        self.targetResponse = targetResponse
        self.escalation = escalation
        self.tags = tags
    }
}

enum RoadmapDecision: String, Codable, CaseIterable {
    case accelerate = "Accelerate"
    case stabilize = "Stabilize"
    case reposition = "Reposition"
    case bundle = "Bundle"
    case simplify = "Simplify"
}

struct RoadmapRecommendation: Codable, Identifiable, Hashable {
    let id: UUID
    let appName: String
    let decision: RoadmapDecision
    let rationale: String
    let actions: [String]

    init(id: UUID = UUID(), appName: String, decision: RoadmapDecision, rationale: String, actions: [String]) {
        self.id = id
        self.appName = appName
        self.decision = decision
        self.rationale = rationale
        self.actions = actions
    }
}

struct TelemetryCoverageReport: Codable, Identifiable, Hashable {
    let id: UUID
    let appName: String
    let requiredEvents: [String]
    let observedEvents: [String]
    let missingEvents: [String]
    let isComplete: Bool

    init(id: UUID = UUID(), appName: String, requiredEvents: [String], observedEvents: [String]) {
        self.id = id
        self.appName = appName
        self.requiredEvents = requiredEvents
        self.observedEvents = observedEvents
        self.missingEvents = requiredEvents.filter { !observedEvents.contains($0) }
        self.isComplete = missingEvents.isEmpty
    }
}

struct MonitoringEngineDescriptor: Codable, Identifiable, Hashable {
    let id: UUID
    let name: String
    let purpose: String
    let status: String

    init(id: UUID = UUID(), name: String, purpose: String, status: String = "Installed") {
        self.id = id
        self.name = name
        self.purpose = purpose
        self.status = status
    }
}

struct PostLaunchMonitoringEngine {
    let descriptors: [MonitoringEngineDescriptor] = [
        MonitoringEngineDescriptor(name: "Weekly scorecard engine", purpose: "Aggregates installs, conversion, retention, ratings, crash-free rate, support load, and core value completion."),
        MonitoringEngineDescriptor(name: "Rating generation engine", purpose: "Prompts only after successful task completion, suppresses after errors, and routes unhappy users to support."),
        MonitoringEngineDescriptor(name: "Review triage engine", purpose: "Classifies App Store feedback into bugs, UX confusion, trust concerns, pricing friction, missing features, and support requests."),
        MonitoringEngineDescriptor(name: "Support SLA engine", purpose: "Applies response targets by outage, paid workflow blocker, bug, and education/content question."),
        MonitoringEngineDescriptor(name: "Roadmap decision engine", purpose: "Recommends accelerate, stabilize, reposition, bundle, or simplify based on performance evidence."),
        MonitoringEngineDescriptor(name: "Telemetry coverage engine", purpose: "Checks whether each app captures required acquisition, activation, engagement, monetization, quality, support, and trust events.")
    ]

    func scorecard(
        snapshots: [PostLaunchWeeklySnapshot],
        profiles: [PostLaunchAppPerformanceProfile]
    ) -> PortfolioScorecard {
        guard !snapshots.isEmpty else {
            return PortfolioScorecard(
                appCount: 0,
                totalNewInstalls: 0,
                averageStoreConversionRate: 0,
                averageDay30Retention: 0,
                averageRating: 0,
                totalRatingCount: 0,
                averageCrashFreeUsersRate: 0,
                averageSupportTicketsPer100Users: 0,
                averageCoreValueCompletionRate: 0,
                zeroRatingAppNames: [],
                riskSummary: "No post-launch snapshots loaded."
            )
        }

        let zeroRatingAppNames = profiles
            .filter { profile in
                snapshots.first(where: { $0.appName == profile.appName })?.ratingCount == 0
            }
            .map(\.appName)

        let highSupportCount = snapshots.filter { $0.supportTicketsPer100Users >= 8 }.count
        let reliabilityRiskCount = snapshots.filter { $0.crashFreeUsersRate < 0.98 || $0.recentErrorCount > 0 }.count
        let riskSummary: String
        if !zeroRatingAppNames.isEmpty {
            riskSummary = "Ratings generation remains the leading portfolio risk."
        } else if reliabilityRiskCount > 0 {
            riskSummary = "Reliability stabilization should lead the next release review."
        } else if highSupportCount > 0 {
            riskSummary = "Support load requires product and documentation review."
        } else {
            riskSummary = "Portfolio monitoring signals are inside expected bounds."
        }

        return PortfolioScorecard(
            appCount: snapshots.count,
            totalNewInstalls: snapshots.reduce(0) { $0 + $1.newInstalls },
            averageStoreConversionRate: average(snapshots.map(\.storeConversionRate)),
            averageDay30Retention: average(snapshots.map(\.day30Retention)),
            averageRating: average(snapshots.map(\.averageRating)),
            totalRatingCount: snapshots.reduce(0) { $0 + $1.ratingCount },
            averageCrashFreeUsersRate: average(snapshots.map(\.crashFreeUsersRate)),
            averageSupportTicketsPer100Users: average(snapshots.map(\.supportTicketsPer100Users)),
            averageCoreValueCompletionRate: average(snapshots.map(\.coreValueCompletionRate)),
            zeroRatingAppNames: zeroRatingAppNames,
            riskSummary: riskSummary
        )
    }

    func ratingPromptDecision(
        snapshot: PostLaunchWeeklySnapshot,
        profile: PostLaunchAppPerformanceProfile
    ) -> RatingPromptDecision {
        if snapshot.recentErrorCount > 0 || snapshot.crashFreeUsersRate < 0.98 {
            return RatingPromptDecision(
                appName: profile.appName,
                shouldPrompt: false,
                reason: "Suppress public rating prompt because recent quality signals are not clean.",
                nextAction: "Route users to support and fix reliability issues before asking for reviews."
            )
        }

        if snapshot.engagedSessions < 3 || snapshot.successfulCoreActions < 2 {
            return RatingPromptDecision(
                appName: profile.appName,
                shouldPrompt: false,
                reason: "User has not completed enough meaningful sessions or core-value actions.",
                nextAction: "Wait for successful task completion before prompting."
            )
        }

        if snapshot.daysSinceLastRatingPrompt < 30 {
            return RatingPromptDecision(
                appName: profile.appName,
                shouldPrompt: false,
                reason: "Rating prompt was shown recently.",
                nextAction: "Delay until the prompt cooldown has passed."
            )
        }

        let professionalTone = profile.category == .news || profile.category == .medical
        return RatingPromptDecision(
            appName: profile.appName,
            shouldPrompt: true,
            reason: "Successful core actions, engaged sessions, no recent errors, and prompt cooldown are all satisfied.",
            nextAction: professionalTone
                ? "Ask for authentic feedback from experienced users after value delivery."
                : "Show the in-app rating prompt after the completed save, share, lesson, or report moment."
        )
    }

    func reviewTriage(
        appName: String,
        reviewText: String,
        starRating: Int
    ) -> ReviewTriageResult {
        let text = reviewText.lowercased()
        let category: ReviewIssueCategory
        if text.contains("crash") || text.contains("bug") || text.contains("failed") || text.contains("sync") {
            category = .bug
        } else if text.contains("trust") || text.contains("source") || text.contains("privacy") || text.contains("wrong") {
            category = .trustConcern
        } else if text.contains("price") || text.contains("refund") || text.contains("expensive") || text.contains("purchase") {
            category = .pricingFriction
        } else if text.contains("confusing") || text.contains("hard") || text.contains("unclear") {
            category = .uxConfusion
        } else if text.contains("please add") || text.contains("missing") || text.contains("need") {
            category = .missingFeature
        } else {
            category = .supportRequest
        }

        let severity: MonitoringSeverity = starRating <= 2 || category == .trustConcern || category == .bug
            ? .warning
            : .info

        return ReviewTriageResult(
            appName: appName,
            category: category,
            severity: severity,
            route: route(for: category),
            roadmapSignal: roadmapSignal(for: category)
        )
    }

    func supportTriage(
        ticket: SupportTicketInput,
        profile: PostLaunchAppPerformanceProfile
    ) -> SupportTriageResult {
        let issue = ticket.issueType.lowercased()
        let targetResponse: String
        if ticket.severity == .critical || issue.contains("outage") {
            targetResponse = "Same day response"
        } else if profile.isPaid && (issue.contains("billing") || issue.contains("purchase") || issue.contains("workflow") || issue.contains("export")) {
            targetResponse = "Within one business day"
        } else if issue.contains("content") || issue.contains("education") || issue.contains("lesson") {
            targetResponse = "Within three business days"
        } else {
            targetResponse = "Within two business days"
        }

        let escalation: String
        if profile.category == .medical {
            escalation = "Route through health-adjacent support with privacy and consent checks."
        } else if profile.category == .news {
            escalation = "Route through trust and challenge workflow before public response."
        } else {
            escalation = "Route to product support and document the pattern for roadmap review."
        }

        return SupportTriageResult(
            appName: ticket.appName,
            issueType: ticket.issueType,
            targetResponse: targetResponse,
            escalation: escalation,
            tags: [ticket.appName, ticket.appVersion, ticket.deviceOS, ticket.issueType, ticket.severity.rawValue]
        )
    }

    func roadmapRecommendation(
        snapshot: PostLaunchWeeklySnapshot,
        profile: PostLaunchAppPerformanceProfile
    ) -> RoadmapRecommendation {
        if snapshot.crashFreeUsersRate < 0.98 || snapshot.recentErrorCount > 0 {
            return RoadmapRecommendation(
                appName: profile.appName,
                decision: .stabilize,
                rationale: "Reliability or recent error signals are below the threshold for growth work.",
                actions: ["Prioritize crash and sync fixes", "Suppress rating prompts after errors", "Review support tickets by device and app version"]
            )
        }

        if profile.isPaid && snapshot.storeConversionRate < 0.035 {
            return RoadmapRecommendation(
                appName: profile.appName,
                decision: .reposition,
                rationale: "Paid product conversion is low relative to its pricing and category expectations.",
                actions: ["Refresh App Store screenshots", "Clarify premium value", "Review price and refund signals by country"]
            )
        }

        if profile.appName == "WCSLIB" || snapshot.day30Retention >= 0.28 {
            return RoadmapRecommendation(
                appName: profile.appName,
                decision: .bundle,
                rationale: "Retention or knowledge-hub role supports cross-product pathways.",
                actions: ["Add cross-app recommendations", "Measure assisted conversions", "Prepare bundle and institutional packaging options"]
            )
        }

        if snapshot.coreValueCompletionRate >= 0.70 && snapshot.day7Retention >= 0.35 {
            return RoadmapRecommendation(
                appName: profile.appName,
                decision: .accelerate,
                rationale: "Core-value completion and day-7 retention support expansion.",
                actions: ["Scale the strongest engagement loop", "Add lifecycle messaging", "Prepare quarterly feature release"]
            )
        }

        return RoadmapRecommendation(
            appName: profile.appName,
            decision: .simplify,
            rationale: "Value realization is not yet strong enough for expansion.",
            actions: ["Reduce onboarding friction", "Improve first-session guidance", "Review underused features"]
        )
    }

    func telemetryCoverage(
        profile: PostLaunchAppPerformanceProfile,
        taxonomy: [EventTaxonomyGroup],
        observedEvents: [String]
    ) -> TelemetryCoverageReport {
        let taxonomyEvents = taxonomy.flatMap(\.exampleEvents)
        let requiredEvents = Array(Set(taxonomyEvents + profile.instrumentationEvents)).sorted()
        return TelemetryCoverageReport(
            appName: profile.appName,
            requiredEvents: requiredEvents,
            observedEvents: observedEvents.sorted()
        )
    }

    static func demoSnapshots(for profiles: [PostLaunchAppPerformanceProfile]) -> [PostLaunchWeeklySnapshot] {
        profiles.enumerated().map { index, profile in
            let isPremiumAnalytics = profile.appName == "Psychosocial Analytics"
            let isTrustProduct = profile.appName == "TruthLens Global"
            return PostLaunchWeeklySnapshot(
                appName: profile.appName,
                newInstalls: 42 + index * 11,
                storeConversionRate: profile.isPaid ? 0.028 + Double(index) * 0.002 : 0.112,
                day1Retention: 0.46 - Double(index) * 0.012,
                day7Retention: 0.32 - Double(index) * 0.006,
                day30Retention: profile.appName == "WCSLIB" ? 0.31 : 0.19 + Double(index) * 0.007,
                averageRating: 0,
                ratingCount: profile.visibleRatingCount,
                crashFreeUsersRate: isPremiumAnalytics ? 0.976 : 0.992 - Double(index) * 0.001,
                crashFreeSessionsRate: isPremiumAnalytics ? 0.981 : 0.994 - Double(index) * 0.001,
                supportTicketsPer100Users: isTrustProduct ? 8.4 : 3.5 + Double(index) * 0.45,
                coreValueCompletionRate: 0.62 + Double(index) * 0.018,
                recentErrorCount: isPremiumAnalytics ? 2 : 0,
                engagedSessions: 4 + index,
                successfulCoreActions: 3 + index,
                daysSinceLastRatingPrompt: 45
            )
        }
    }

    private func average(_ values: [Double]) -> Double {
        guard !values.isEmpty else { return 0 }
        return values.reduce(0, +) / Double(values.count)
    }

    private func route(for category: ReviewIssueCategory) -> String {
        switch category {
        case .bug: "Engineering triage"
        case .uxConfusion: "Product design review"
        case .trustConcern: "Governance and trust review"
        case .pricingFriction: "Growth and pricing review"
        case .missingFeature: "Roadmap intake"
        case .supportRequest: "Support queue"
        }
    }

    private func roadmapSignal(for category: ReviewIssueCategory) -> String {
        switch category {
        case .bug: "Stabilize before feature expansion."
        case .uxConfusion: "Simplify onboarding or first-value flow."
        case .trustConcern: "Add transparent explanations and challenge handling."
        case .pricingFriction: "Review pricing, packaging, and App Store value proof."
        case .missingFeature: "Compare request frequency before roadmap inclusion."
        case .supportRequest: "Improve help content and in-app support routing."
        }
    }
}

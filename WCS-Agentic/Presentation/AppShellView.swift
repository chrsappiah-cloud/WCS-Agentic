//
//  AppShellView.swift
//  WCS-Agentic
//

import SwiftData
import SwiftUI

/// Root navigation shell: tabs, session bootstrap, subscription sync.
struct AppShellView: View {
    let api: APIServing
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var session: SessionManager
    @EnvironmentObject private var subscription: SubscriptionManager
    @StateObject private var programsVM: ProgramsViewModel
    @State private var selectedTab: AppShellTab

    init(api: APIServing) {
        self.api = api
        _programsVM = StateObject(wrappedValue: ProgramsViewModel(api: api))
        _selectedTab = State(initialValue: AppShellTab.initialSelection(from: ProcessInfo.processInfo.arguments))
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                FinanceAgentConsoleView(api: api)
            }
            .tabItem { Label("Finance AI", systemImage: "building.2.crop.circle") }
            .accessibilityIdentifier("tab.financeAI")
            .tag(AppShellTab.finance)

            NavigationStack {
                LegalDeepSeekConsoleView()
            }
            .tabItem { Label("Legal AI", systemImage: "building.columns") }
            .accessibilityIdentifier("tab.legalAI")
            .tag(AppShellTab.legal)

            NavigationStack {
                ProgramsHomeView(
                    viewModel: programsVM,
                    repository: WorkflowRepository(modelContext: modelContext)
                )
            }
            .tabItem { Label("Programs", systemImage: "person.3.fill") }
            .accessibilityIdentifier("tab.programs")
            .tag(AppShellTab.programs)

            NavigationStack {
                AgentsHubView()
            }
            .tabItem { Label("Agents", systemImage: "sparkles") }
            .accessibilityIdentifier("tab.agents")
            .tag(AppShellTab.agents)

            NavigationStack {
                PlatformBlueprintConsoleView()
            }
            .tabItem { Label("Blueprint", systemImage: "map") }
            .accessibilityIdentifier("tab.blueprint")
            .tag(AppShellTab.blueprint)

            NavigationStack {
                ApprovalsQueueView()
            }
            .tabItem { Label("Approvals", systemImage: "checkmark.circle") }
            .accessibilityIdentifier("tab.approvals")
            .tag(AppShellTab.approvals)

            NavigationStack {
                MonitoringDashboardView(programsVM: programsVM)
            }
            .tabItem { Label("Monitor", systemImage: "chart.xyaxis.line") }
            .accessibilityIdentifier("tab.monitor")
            .tag(AppShellTab.monitor)

            NavigationStack {
                BackendStatusView(
                    viewModel: programsVM,
                    repository: WorkflowRepository(modelContext: modelContext)
                )
            }
            .tabItem { Label("API", systemImage: "antenna.radiowaves.left.and.right") }
            .accessibilityIdentifier("tab.api")
            .tag(AppShellTab.api)

            NavigationStack {
                AccountAccessView()
            }
            .tabItem { Label("Account", systemImage: "person.crop.circle") }
            .accessibilityIdentifier("tab.account")
            .tag(AppShellTab.account)

            if session.isAdmin {
                NavigationStack {
                    AdminPanelView()
                }
                .tabItem { Label("Admin", systemImage: "lock.shield") }
                .accessibilityIdentifier("tab.admin")
                .tag(AppShellTab.admin)
            }
        }
        .tint(AgenticTheme.emerald)
        .onAppear {
            session.attach(modelContext: modelContext)
            bootstrapMonitoring()
            if ProcessInfo.processInfo.arguments.contains("--uitesting") {
                let repo = UserAccountRepository(modelContext: modelContext)
                session.signInAsDemoAdmin()
                try? subscription.activateSandboxTrial(session: session, userRepo: repo)
            }
        }
    }

    private func bootstrapMonitoring() {
        let monitoring = MonitoringRepository(modelContext: modelContext)
        try? monitoring.log(source: "App", message: "Session shell ready", severity: .info)
    }
}

private enum AppShellTab: Hashable {
    case finance
    case legal
    case programs
    case agents
    case blueprint
    case approvals
    case monitor
    case api
    case account
    case admin

    static func initialSelection(from arguments: [String]) -> AppShellTab {
        if arguments.contains("--start-legal") {
            return .legal
        }
        if arguments.contains("--start-programs") {
            return .programs
        }
        if arguments.contains("--start-agents") {
            return .agents
        }
        if arguments.contains("--start-blueprint") {
            return .blueprint
        }
        if arguments.contains("--start-approvals") {
            return .approvals
        }
        if arguments.contains("--start-monitor") {
            return .monitor
        }
        if arguments.contains("--start-api") {
            return .api
        }
        if arguments.contains("--start-account") {
            return .account
        }
        if arguments.contains("--start-admin") {
            return .admin
        }
        return .finance
    }
}

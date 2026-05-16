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

    init(api: APIServing) {
        self.api = api
        _programsVM = StateObject(wrappedValue: ProgramsViewModel(api: api))
    }

    var body: some View {
        TabView {
            NavigationStack {
                ProgramsHomeView(
                    viewModel: programsVM,
                    repository: WorkflowRepository(modelContext: modelContext)
                )
            }
            .tabItem { Label("Programs", systemImage: "person.3.fill") }
            .accessibilityIdentifier("tab.programs")

            NavigationStack {
                AgentsHubView()
            }
            .tabItem { Label("Agents", systemImage: "sparkles") }
            .accessibilityIdentifier("tab.agents")

            NavigationStack {
                MonitoringDashboardView(programsVM: programsVM)
            }
            .tabItem { Label("Monitor", systemImage: "chart.xyaxis.line") }
            .accessibilityIdentifier("tab.monitor")

            NavigationStack {
                BackendStatusView(
                    viewModel: programsVM,
                    repository: WorkflowRepository(modelContext: modelContext)
                )
            }
            .tabItem { Label("API", systemImage: "antenna.radiowaves.left.and.right") }
            .accessibilityIdentifier("tab.api")

            NavigationStack {
                AccountAccessView()
            }
            .tabItem { Label("Account", systemImage: "person.crop.circle") }
            .accessibilityIdentifier("tab.account")

            if session.isAdmin {
                NavigationStack {
                    AdminPanelView()
                }
                .tabItem { Label("Admin", systemImage: "lock.shield") }
                .accessibilityIdentifier("tab.admin")
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

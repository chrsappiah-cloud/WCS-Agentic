//
//  WCS_AgenticApp.swift
//  WCS-Agentic
//

import SwiftData
import SwiftUI

@main
struct WCS_AgenticApp: App {
    @StateObject private var session = SessionManager()
    @StateObject private var subscription = SubscriptionManager()

    private let sharedModelContainer: ModelContainer
    private let api: APIServing

    init() {
        let schema = Schema([
            ParticipantRecord.self,
            UserAccountRecord.self,
            AgentRunRecord.self,
            MonitoringEventRecord.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            sharedModelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
        if ProcessInfo.processInfo.arguments.contains("--uitesting") {
            api = MockBackendClient()
        } else {
            api = VaporBackendClient()
        }
    }

    var body: some Scene {
        WindowGroup {
            AppShellView(api: api)
                .modelContainer(sharedModelContainer)
                .environmentObject(session)
                .environmentObject(subscription)
        }
    }
}

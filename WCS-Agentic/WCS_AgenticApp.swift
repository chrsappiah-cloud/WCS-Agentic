//
//  WCS_AgenticApp.swift
//  WCS-Agentic
//

import SwiftData
import SwiftUI

@main
struct WCS_AgenticApp: App {
    private let sharedModelContainer: ModelContainer
    private let api: APIServing

    init() {
        let schema = Schema([ParticipantRecord.self])
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
            RootView(api: api)
                .modelContainer(sharedModelContainer)
        }
    }
}

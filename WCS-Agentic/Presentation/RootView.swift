//
//  RootView.swift
//  WCS-Agentic
//

import SwiftData
import SwiftUI

struct RootView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var programsVM: ProgramsViewModel

    init(api: APIServing) {
        _programsVM = StateObject(wrappedValue: ProgramsViewModel(api: api))
    }

    var body: some View {
        TabView {
            NavigationStack {
                ProgramsHomeView(viewModel: programsVM, repository: WorkflowRepository(modelContext: modelContext))
            }
            .tabItem { Label("Programs", systemImage: "person.3.fill") }
            .accessibilityIdentifier("tab.programs")

            NavigationStack {
                BackendStatusView(viewModel: programsVM, repository: WorkflowRepository(modelContext: modelContext))
            }
            .tabItem { Label("API", systemImage: "antenna.radiowaves.left.and.right") }
            .accessibilityIdentifier("tab.api")
        }
    }
}

struct ProgramsHomeView: View {
    @ObservedObject var viewModel: ProgramsViewModel
    let repository: WorkflowRepository
    @Query(sort: \ParticipantRecord.createdAt, order: .reverse) private var participants: [ParticipantRecord]

    var body: some View {
        List {
            Section("Participants (SwiftData)") {
                if participants.isEmpty {
                    Text("No rows yet. Enroll a sample or connect the Vapor API.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(participants, id: \.id) { p in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(p.fullName).font(.headline)
                            Text(p.email).font(.subheadline).foregroundStyle(.secondary)
                            Text("Status: \(p.status)").font(.caption)
                        }
                        .accessibilityElement(children: .combine)
                    }
                }
            }
        }
        .navigationTitle("World Class Scholars")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Refresh API") {
                    Task { await viewModel.refreshHealth() }
                }
                .accessibilityIdentifier("toolbar.refreshHealth")
            }
            ToolbarItem(placement: .bottomBar) {
                Button("Enroll sample") {
                    Task {
                        await viewModel.enrollSample(
                            email: "sample@worldclassscholars.test",
                            fullName: "Sample Scholar",
                            repository: repository
                        )
                    }
                }
                .accessibilityIdentifier("toolbar.enrollSample")
            }
        }
        .overlay(alignment: .top) {
            if viewModel.isBusy {
                ProgressView()
                    .padding()
                    .background(.ultraThinMaterial, in: Capsule())
                    .accessibilityIdentifier("overlay.busy")
            }
        }
        .task {
            await viewModel.refreshHealth()
        }
    }
}

struct BackendStatusView: View {
    @ObservedObject var viewModel: ProgramsViewModel
    let repository: WorkflowRepository

    var body: some View {
        Form {
            Section("Backend health") {
                Text(viewModel.lastHealth)
                    .font(.title2.monospaced())
                    .accessibilityIdentifier("api.healthValue")
                if let err = viewModel.lastError {
                    Text(err)
                        .foregroundStyle(.red)
                        .accessibilityIdentifier("api.errorText")
                }
            }
            Section {
                Text("Set `WCSAPIBaseURL` in Info.plist for your Vapor service. `--uitesting` uses MockBackendClient.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Middleware & API")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Ping") {
                    Task { await viewModel.refreshHealth() }
                }
                .accessibilityIdentifier("toolbar.pingApi")
            }
            ToolbarItem(placement: .bottomBar) {
                Button("Enroll from API tab") {
                    Task {
                        await viewModel.enrollSample(
                            email: "api-tab@worldclassscholars.test",
                            fullName: "API Tab Scholar",
                            repository: repository
                        )
                    }
                }
                .accessibilityIdentifier("toolbar.enrollFromApiTab")
            }
        }
    }
}

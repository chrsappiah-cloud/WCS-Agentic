//
//  RootView.swift
//  WCS-Agentic
//

import SwiftData
import SwiftUI

struct ProgramsHomeView: View {
    @ObservedObject var viewModel: ProgramsViewModel
    let repository: WorkflowRepository
    @Query(sort: \ParticipantRecord.createdAt, order: .reverse) private var participants: [ParticipantRecord]

    var body: some View {
        List {
            Section {
                AgenticHeroHeader(
                    title: "Scholar Workspace",
                    subtitle: "A calm command center for programs, participants, and supervised automation—aligned to your Vapor API and SwiftData cache."
                )
                .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 8, trailing: 16))
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }

            Section {
                if participants.isEmpty {
                    GlassCard {
                        VStack(alignment: .leading, spacing: 10) {
                            Label("No participants yet", systemImage: "tray")
                                .font(.headline)
                            Text("Connect your backend, refresh health, then enroll a sample to mirror a live onboarding run.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                } else {
                    ForEach(participants, id: \.id) { p in
                        GlassCard {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text(p.fullName)
                                        .font(.headline)
                                    Spacer(minLength: 8)
                                    Text(p.status.uppercased())
                                        .font(.caption.weight(.semibold))
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 4)
                                        .background(AgenticTheme.emerald.opacity(0.14))
                                        .foregroundStyle(AgenticTheme.emerald)
                                        .clipShape(Capsule(style: .continuous))
                                }
                                Text(p.email)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .accessibilityElement(children: .combine)
                    }
                }
            } header: {
                Text("Participants")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .textCase(nil)
            }
        }
        .scrollContentBackground(.hidden)
        .background(AgenticTheme.pageBackground.ignoresSafeArea())
        .navigationTitle("World Class Scholars")
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Refresh API") {
                    Task { await viewModel.refreshHealth() }
                }
                .accessibilityIdentifier("toolbar.refreshHealth")
            }
            ToolbarItem(placement: .bottomBar) {
                Menu {
                    Button {
                        Task {
                            await viewModel.enrollSample(
                                email: "sample@worldclassscholars.test",
                                fullName: "Sample Scholar",
                                repository: repository
                            )
                        }
                    } label: {
                        Label("Enroll via Vapor API", systemImage: "person.badge.plus")
                    }
                    .accessibilityIdentifier("programs.enrollSample")
                    Button {
                        Task {
                            await viewModel.submitIdentity(
                                participantID: participants.first?.id,
                                repository: repository
                            )
                        }
                    } label: {
                        Label("Submit mock ID document", systemImage: "doc.badge.plus")
                    }
                } label: {
                    Label("Actions", systemImage: "ellipsis.circle")
                }
                .accessibilityIdentifier("toolbar.programActions")
            }
        }
        .overlay(alignment: .top) {
            if viewModel.isBusy {
                ProgressView()
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(.ultraThinMaterial, in: Capsule())
                    .overlay(
                        Capsule(style: .continuous)
                            .strokeBorder(Color.primary.opacity(0.08), lineWidth: 1)
                    )
                    .padding(.top, 8)
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
        List {
            Section {
                AgenticHeroHeader(
                    title: "Systems & Integrations",
                    subtitle: "Health, errors, and API wiring—styled like a modern agent console, grounded in explicit contracts and testable seams."
                )
                .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 8, trailing: 16))
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }

            Section {
                GlassCard {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Backend health")
                                .font(.headline)
                            Spacer()
                            Image(systemName: "waveform.path.ecg")
                                .foregroundStyle(AgenticTheme.emerald)
                                .accessibilityHidden(true)
                        }

                        HealthStatusPill(text: viewModel.lastHealth)
                            .accessibilityIdentifier("api.healthValue")

                        if let err = viewModel.lastError {
                            Text(err)
                                .font(.footnote)
                                .foregroundStyle(.red)
                                .padding(12)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .fill(Color.red.opacity(0.08))
                                )
                                .accessibilityIdentifier("api.errorText")
                        }
                    }
                }
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }

            Section {
                GlassCard {
                    VStack(alignment: .leading, spacing: 10) {
                        Label("Operator notes", systemImage: "doc.text")
                            .font(.headline)
                        Text("Set `WCSAPIBaseURL` (Vapor, :8080) and `WCSOrchestratorBaseURL` (:3000) in Info.plist. `--uitesting` uses mocks.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }
        }
        .scrollContentBackground(.hidden)
        .background(AgenticTheme.pageBackground.ignoresSafeArea())
        .navigationTitle("Middleware & API")
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Ping") {
                    Task { await viewModel.refreshHealth() }
                }
                .accessibilityIdentifier("toolbar.pingApi")
            }
            ToolbarItem(placement: .bottomBar) {
                Button {
                    Task {
                        await viewModel.enrollSample(
                            email: "api-tab@worldclassscholars.test",
                            fullName: "API Tab Scholar",
                            repository: repository
                        )
                    }
                } label: {
                    Label("Enroll from API tab", systemImage: "arrow.triangle.branch")
                }
                .accessibilityIdentifier("toolbar.enrollFromApiTab")
            }
        }
    }
}

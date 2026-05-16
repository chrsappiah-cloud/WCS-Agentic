//
//  AccountAccessView.swift
//  WCS-Agentic
//

import SwiftData
import SwiftUI

struct AccountAccessView: View {
    @EnvironmentObject private var session: SessionManager
    @EnvironmentObject private var subscription: SubscriptionManager
    @Environment(\.modelContext) private var modelContext

    @State private var email = ""
    @State private var displayName = ""

    var body: some View {
        List {
            Section {
                AgenticHeroHeader(
                    title: "Account & Access",
                    subtitle: "Sign in, manage your subscription for TestFlight sandbox testing, and control who can run supervised agents."
                )
                .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 8, trailing: 16))
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }

            if session.isSignedIn, let user = session.currentUser {
                Section {
                    GlassCard {
                        VStack(alignment: .leading, spacing: 10) {
                            Label(user.displayName, systemImage: "person.crop.circle")
                                .font(.headline)
                            Text(user.email).font(.subheadline).foregroundStyle(.secondary)
                            HStack {
                                Text("Role: \(user.role.displayName)")
                                Spacer()
                                Text(user.subscriptionTier.displayName)
                                    .font(.caption.weight(.semibold))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(AgenticTheme.bronze.opacity(0.2))
                                    .clipShape(Capsule())
                            }
                            .font(.caption)
                            Text(user.isAccessEnabled ? "Access enabled" : "Access disabled")
                                .font(.caption)
                                .foregroundStyle(user.isAccessEnabled ? AgenticTheme.emerald : .red)
                        }
                    }
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .accessibilityIdentifier("account.profileCard")
                }

                Section {
                    GlassCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Subscription (TestFlight / Sandbox)")
                                .font(.headline)
                            Text(subscription.statusMessage)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            if let err = subscription.lastError {
                                Text(err).font(.footnote).foregroundStyle(.red)
                            }
                            if subscription.isLoading {
                                ProgressView()
                            }
                            Button("Load subscription product") {
                                Task { await subscription.loadProducts() }
                            }
                            .accessibilityIdentifier("account.loadProducts")
                            Button("Subscribe to Pro (sandbox)") {
                                Task {
                                    await subscription.purchasePro()
                                    syncSubscriptionToUser()
                                }
                            }
                            .accessibilityIdentifier("account.subscribePro")
                            Button("Restore purchases") {
                                Task {
                                    await subscription.restorePurchases()
                                    syncSubscriptionToUser()
                                }
                            }
                            .accessibilityIdentifier("account.restorePurchases")
                            #if DEBUG
                            Button("Activate sandbox trial (dev)") {
                                activateSandboxTrial()
                            }
                            .accessibilityIdentifier("account.sandboxTrial")
                            #endif
                        }
                    }
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                }

                Section {
                    Button("Sign out", role: .destructive) {
                        session.signOut()
                    }
                    .accessibilityIdentifier("account.signOut")
                }
            } else {
                Section {
                    TextField("Email", text: $email)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .accessibilityIdentifier("account.emailField")
                    TextField("Display name", text: $displayName)
                        .accessibilityIdentifier("account.nameField")
                    Button("Sign in") {
                        session.signIn(email: email, displayName: displayName.isEmpty ? email : displayName)
                        syncSubscriptionToUser()
                    }
                    .accessibilityIdentifier("account.signIn")
                    Button("Quick sign-in (demo admin)") {
                        session.signInAsDemoAdmin()
                        syncSubscriptionToUser()
                    }
                    .accessibilityIdentifier("account.demoAdminSignIn")
                    if let err = session.lastError {
                        Text(err).foregroundStyle(.red).font(.footnote)
                    }
                } header: {
                    Text("Sign in")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .textCase(nil)
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(AgenticTheme.pageBackground.ignoresSafeArea())
        .navigationTitle("Account")
        .navigationBarTitleDisplayMode(.large)
        .task {
            await subscription.loadProducts()
            syncSubscriptionToUser()
        }
    }

    private func syncSubscriptionToUser() {
        let repo = UserAccountRepository(modelContext: modelContext)
        try? subscription.applyEntitlementToUser(session: session, userRepo: repo)
    }

    private func activateSandboxTrial() {
        let repo = UserAccountRepository(modelContext: modelContext)
        try? subscription.activateSandboxTrial(session: session, userRepo: repo)
    }
}

//
//  AdminPanelView.swift
//  WCS-Agentic
//

import SwiftData
import SwiftUI

struct AdminPanelView: View {
    @EnvironmentObject private var session: SessionManager
    @EnvironmentObject private var subscription: SubscriptionManager
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \UserAccountRecord.createdAt, order: .reverse) private var users: [UserAccountRecord]

    var body: some View {
        List {
            Section {
                AgenticHeroHeader(
                    title: "Admin Console",
                    subtitle: "Control user access, roles, and subscription tiers. Payment state syncs from StoreKit entitlements when users restore purchases."
                )
                .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 8, trailing: 16))
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }

            if !session.isAdmin {
                GlassCard {
                    Text("Admin role required. Sign in as admin@worldclassscholars.test or promote your account.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                .accessibilityIdentifier("admin.denied")
            } else {
                Section {
                    ForEach(users, id: \.id) { user in
                        GlassCard {
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Text(user.displayName).font(.headline)
                                    Spacer()
                                    if !user.isAccessEnabled {
                                        Text("LOCKED")
                                            .font(.caption2.weight(.bold))
                                            .foregroundStyle(.red)
                                    }
                                }
                                Text(user.email).font(.caption).foregroundStyle(.secondary)

                                Picker("Role", selection: roleBinding(for: user)) {
                                    ForEach(UserRole.allCases, id: \.self) { role in
                                        Text(role.displayName).tag(role)
                                    }
                                }
                                .accessibilityIdentifier("admin.role.\(user.email)")

                                Picker("Subscription", selection: tierBinding(for: user)) {
                                    ForEach(SubscriptionTier.allCases, id: \.self) { tier in
                                        Text(tier.displayName).tag(tier)
                                    }
                                }
                                .accessibilityIdentifier("admin.tier.\(user.email)")

                                Toggle("Access enabled", isOn: accessBinding(for: user))
                                    .accessibilityIdentifier("admin.access.\(user.email)")
                            }
                        }
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                    }
                } header: {
                    Text("Users & payments")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .textCase(nil)
                }

                Section {
                    Button("Sync StoreKit entitlements for current user") {
                        let repo = UserAccountRepository(modelContext: modelContext)
                        Task {
                            await subscription.restorePurchases()
                            try? subscription.applyEntitlementToUser(session: session, userRepo: repo)
                            try? MonitoringRepository(modelContext: modelContext).log(
                                source: "Admin",
                                message: "Manual entitlement sync requested",
                                severity: .info
                            )
                        }
                    }
                    .accessibilityIdentifier("admin.syncEntitlements")
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(AgenticTheme.pageBackground.ignoresSafeArea())
        .navigationTitle("Admin")
        .navigationBarTitleDisplayMode(.large)
    }

    private func roleBinding(for user: UserAccountRecord) -> Binding<UserRole> {
        Binding(
            get: { user.role },
            set: { newValue in
                let repo = UserAccountRepository(modelContext: modelContext)
                try? repo.setRole(id: user.id, role: newValue)
                session.refreshCurrentUser()
                try? MonitoringRepository(modelContext: modelContext).log(
                    source: "Admin",
                    message: "Role changed to \(newValue.displayName) for \(user.email)",
                    severity: .warning
                )
            }
        )
    }

    private func tierBinding(for user: UserAccountRecord) -> Binding<SubscriptionTier> {
        Binding(
            get: { user.subscriptionTier },
            set: { newValue in
                let repo = UserAccountRepository(modelContext: modelContext)
                try? repo.setSubscriptionTier(id: user.id, tier: newValue)
                session.refreshCurrentUser()
                try? MonitoringRepository(modelContext: modelContext).log(
                    source: "Admin",
                    message: "Subscription set to \(newValue.displayName) for \(user.email)",
                    severity: .info
                )
            }
        )
    }

    private func accessBinding(for user: UserAccountRecord) -> Binding<Bool> {
        Binding(
            get: { user.isAccessEnabled },
            set: { enabled in
                let repo = UserAccountRepository(modelContext: modelContext)
                try? repo.setAccessEnabled(id: user.id, enabled: enabled)
                session.refreshCurrentUser()
                try? MonitoringRepository(modelContext: modelContext).log(
                    source: "Admin",
                    message: "Access \(enabled ? "enabled" : "disabled") for \(user.email)",
                    severity: enabled ? .info : .critical
                )
            }
        )
    }
}

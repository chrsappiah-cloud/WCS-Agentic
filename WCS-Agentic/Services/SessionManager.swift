//
//  SessionManager.swift
//  WCS-Agentic
//

import Combine
import Foundation
import SwiftData

@MainActor
final class SessionManager: ObservableObject {
    @Published private(set) var currentUser: UserAccountRecord?
    @Published private(set) var lastError: String?

    private var userRepo: UserAccountRepository?

    var isSignedIn: Bool { currentUser != nil }

    var isAdmin: Bool { currentUser?.role == .admin }

    var canRunAgents: Bool {
        guard let user = currentUser, user.isAccessEnabled else { return false }
        return user.role.canRunAgents && user.subscriptionTier.allowsAgentAutomation
    }

    func attach(modelContext: ModelContext) {
        userRepo = UserAccountRepository(modelContext: modelContext)
        do {
            try userRepo?.seedDefaultsIfEmpty()
        } catch {
            lastError = error.localizedDescription
        }
    }

    func signIn(email: String, displayName: String) {
        guard let userRepo else {
            lastError = "Session not ready"
            return
        }
        lastError = nil
        do {
            let user = try userRepo.upsert(email: email, displayName: displayName)
            guard user.isAccessEnabled else {
                lastError = "Access disabled for this account. Contact an administrator."
                currentUser = nil
                return
            }
            currentUser = user
        } catch {
            lastError = error.localizedDescription
        }
    }

    func signInAsDemoAdmin() {
        signIn(email: "admin@worldclassscholars.test", displayName: "WCS Admin")
    }

    func signOut() {
        currentUser = nil
        lastError = nil
    }

    func refreshCurrentUser() {
        guard let userRepo, let id = currentUser?.id else { return }
        currentUser = try? userRepo.user(id: id)
    }
}

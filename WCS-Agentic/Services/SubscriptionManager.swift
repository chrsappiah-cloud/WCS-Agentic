//
//  SubscriptionManager.swift
//  WCS-Agentic
//

import Combine
import Foundation
import StoreKit

/// StoreKit 2 subscription flow for TestFlight / Sandbox testing.
@MainActor
final class SubscriptionManager: ObservableObject {
    @Published private(set) var products: [Product] = []
    @Published private(set) var purchasedProductIDs: Set<String> = []
    @Published private(set) var statusMessage: String = "Not subscribed"
    @Published private(set) var isLoading = false
    @Published private(set) var lastError: String?

    private let productID: String

    init() {
        if let id = Bundle.main.object(forInfoDictionaryKey: "WCSSubscriptionProductID") as? String, !id.isEmpty {
            productID = id
        } else {
            productID = "wcs.agentic.pro.monthly"
        }
        Task { await listenForTransactions() }
    }

    var isProActive: Bool {
        purchasedProductIDs.contains(productID)
    }

    func loadProducts() async {
        isLoading = true
        lastError = nil
        defer { isLoading = false }
        do {
            products = try await Product.products(for: [productID])
            if products.isEmpty {
                statusMessage = "Product not found in App Store Connect / StoreKit config"
            }
            await refreshEntitlements()
        } catch {
            lastError = error.localizedDescription
            statusMessage = "Unable to load products"
        }
    }

    func purchasePro() async {
        guard let product = products.first(where: { $0.id == productID }) ?? products.first else {
            lastError = "Subscription product unavailable"
            return
        }
        isLoading = true
        lastError = nil
        defer { isLoading = false }
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await transaction.finish()
                await refreshEntitlements()
                statusMessage = "Pro subscription active"
            case .userCancelled:
                statusMessage = "Purchase cancelled"
            case .pending:
                statusMessage = "Purchase pending approval"
            @unknown default:
                statusMessage = "Unknown purchase result"
            }
        } catch {
            lastError = error.localizedDescription
        }
    }

    func restorePurchases() async {
        isLoading = true
        lastError = nil
        defer { isLoading = false }
        do {
            try await AppStore.sync()
            await refreshEntitlements()
            statusMessage = isProActive ? "Restored Pro subscription" : "No active subscription found"
        } catch {
            lastError = error.localizedDescription
        }
    }

    /// Sandbox trial for UI tests / local QA (not a substitute for App Store Connect sandbox IAP).
    func activateSandboxTrial(session: SessionManager, userRepo: UserAccountRepository) throws {
        guard ProcessInfo.processInfo.arguments.contains("--uitesting")
            || ProcessInfo.processInfo.environment["WCS_SANDBOX_TRIAL"] == "1"
            || ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
        else { return }
        guard let user = session.currentUser else { return }
        try userRepo.setSubscriptionTier(id: user.id, tier: .trial)
        session.refreshCurrentUser()
        statusMessage = "Sandbox trial activated"
    }

    func applyEntitlementToUser(session: SessionManager, userRepo: UserAccountRepository) throws {
        guard let user = session.currentUser else { return }
        let tier: SubscriptionTier = isProActive ? .pro : user.subscriptionTier
        try userRepo.setSubscriptionTier(id: user.id, tier: tier)
        session.refreshCurrentUser()
    }

    private func refreshEntitlements() async {
        var active: Set<String> = []
        for await result in Transaction.currentEntitlements {
            guard let transaction = try? checkVerified(result) else { continue }
            if transaction.revocationDate == nil {
                active.insert(transaction.productID)
            }
        }
        purchasedProductIDs = active
        statusMessage = active.contains(productID) ? "Pro subscription active" : "Free tier"
    }

    private func listenForTransactions() async {
        for await result in Transaction.updates {
            guard let transaction = try? checkVerified(result) else { continue }
            await transaction.finish()
            await refreshEntitlements()
        }
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified(_, let error):
            throw error
        case .verified(let safe):
            return safe
        }
    }
}

//
//  ProgramsViewModel.swift
//  WCS-Agentic
//

import Combine
import Foundation

@MainActor
final class ProgramsViewModel: ObservableObject {
    @Published private(set) var lastHealth: String = "—"
    @Published private(set) var lastError: String?
    @Published private(set) var isBusy = false

    let api: APIServing

    init(api: APIServing) {
        self.api = api
    }

    func refreshHealth() async {
        isBusy = true
        lastError = nil
        defer { isBusy = false }
        do {
            lastHealth = try await api.health()
        } catch {
            lastError = error.localizedDescription
            lastHealth = "unavailable"
        }
    }

    func enrollSample(email: String, fullName: String, repository: WorkflowRepository) async {
        isBusy = true
        lastError = nil
        defer { isBusy = false }
        do {
            let id = try await api.createParticipant(email: email, fullName: fullName)
            try repository.upsertParticipant(id: id, email: email, fullName: fullName)
        } catch {
            lastError = error.localizedDescription
        }
    }
}

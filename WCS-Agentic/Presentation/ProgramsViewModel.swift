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
            try repository.upsertParticipant(id: id, email: email, fullName: fullName, status: "pending")
        } catch {
            lastError = error.localizedDescription
        }
    }

    func submitIdentity(participantID: UUID?, repository: WorkflowRepository) async {
        guard let participantID else {
            lastError = "Enroll a participant first."
            return
        }
        isBusy = true
        lastError = nil
        defer { isBusy = false }
        do {
            try await api.uploadIdentity(
                participantID: participantID,
                documentURL: "https://vault.worldclassscholars.test/doc/mock-passport.pdf"
            )
            try repository.updateStatus(id: participantID, status: "identity_submitted")
        } catch {
            lastError = error.localizedDescription
        }
    }
}

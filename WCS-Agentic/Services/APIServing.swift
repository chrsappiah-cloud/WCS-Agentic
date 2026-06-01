//
//  APIServing.swift
//  WCS-Agentic
//

import Foundation

/// Backend contract (Vapor API). Implemented by live client, mocks, and test doubles.
protocol APIServing: Sendable {
    func health() async throws -> String
    func createParticipant(email: String, fullName: String) async throws -> UUID
    func uploadIdentity(participantID: UUID, documentURL: String) async throws
    func approveWorkflow(workflowID: UUID, approvedBy: String) async throws
    func fetchFinanceSnapshot() async throws -> FinanceWorkspaceSnapshot
    func updateAccountingRecordStatus(id: UUID, status: RecordStatus, actor: String) async throws -> FinanceWorkspaceSnapshot
    func completeComplianceTask(id: UUID, actor: String) async throws -> FinanceWorkspaceSnapshot
    func captureGovernanceApprovalNote(id: UUID, actor: String) async throws -> FinanceWorkspaceSnapshot
    func generateFinanceReport(period: String, actor: String) async throws -> GeneratedReportResponse
}

enum APIError: Error, Equatable {
    case invalidURL
    case badStatus(Int)
    case decoding
}

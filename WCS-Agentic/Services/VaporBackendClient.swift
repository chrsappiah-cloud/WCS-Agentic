//
//  VaporBackendClient.swift
//  WCS-Agentic
//

import Foundation

/// Live client for the Swift/Vapor starter (`GET /health`, `POST /participants`).
struct VaporBackendClient: APIServing {
    private let baseURL: URL
    private let http: URLSessionHTTPClient

    init(baseURL: URL? = nil, http: URLSessionHTTPClient = URLSessionHTTPClient()) {
        if let baseURL {
            self.baseURL = baseURL
        } else if let s = ProcessInfo.processInfo.environment["WCS_API_BASE_URL"],
                  let u = URL(string: s)
        {
            self.baseURL = u
        } else if let s = Bundle.main.object(forInfoDictionaryKey: "WCSAPIBaseURL") as? String,
                  let u = URL(string: s)
        {
            self.baseURL = u
        } else {
            self.baseURL = URL(string: "http://127.0.0.1:8080")!
        }
        self.http = http
    }

    func health() async throws -> String {
        let url = baseURL.appendingPathComponent("health")
        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        let (data, response) = try await http.data(for: req)
        guard let http = response as? HTTPURLResponse, (200 ..< 300).contains(http.statusCode) else {
            throw APIError.badStatus((response as? HTTPURLResponse)?.statusCode ?? -1)
        }
        return String(data: data, encoding: .utf8) ?? ""
    }

    func createParticipant(email: String, fullName: String) async throws -> UUID {
        let url = baseURL.appendingPathComponent("participants")
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: String] = ["email": email, "fullName": fullName]
        req.httpBody = try JSONSerialization.data(withJSONObject: body)
        let (data, response) = try await http.data(for: req)
        guard let http = response as? HTTPURLResponse, (200 ..< 300).contains(http.statusCode) else {
            throw APIError.badStatus((response as? HTTPURLResponse)?.statusCode ?? -1)
        }
        struct Row: Decodable {
            let id: UUID?
            let email: String
            let fullName: String
        }
        let row = try JSONDecoder().decode(Row.self, from: data)
        guard let id = row.id else { throw APIError.decoding }
        return id
    }

    func uploadIdentity(participantID: UUID, documentURL: String) async throws {
        let url = baseURL.appendingPathComponent("identity/upload")
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: String] = [
            "participantID": participantID.uuidString,
            "documentURL": documentURL,
        ]
        req.httpBody = try JSONSerialization.data(withJSONObject: body)
        let (_, response) = try await http.data(for: req)
        guard let http = response as? HTTPURLResponse, (200 ..< 300).contains(http.statusCode) else {
            throw APIError.badStatus((response as? HTTPURLResponse)?.statusCode ?? -1)
        }
    }

    func approveWorkflow(workflowID: UUID, approvedBy: String) async throws {
        let url = baseURL.appendingPathComponent("workflows/approve")
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: String] = [
            "workflowID": workflowID.uuidString,
            "approvedBy": approvedBy,
        ]
        req.httpBody = try JSONSerialization.data(withJSONObject: body)
        let (_, response) = try await http.data(for: req)
        guard let http = response as? HTTPURLResponse, (200 ..< 300).contains(http.statusCode) else {
            throw APIError.badStatus((response as? HTTPURLResponse)?.statusCode ?? -1)
        }
    }

    func fetchFinanceSnapshot() async throws -> FinanceWorkspaceSnapshot {
        try await get("finance/snapshot", as: FinanceWorkspaceSnapshot.self)
    }

    func updateAccountingRecordStatus(id: UUID, status: RecordStatus, actor: String) async throws -> FinanceWorkspaceSnapshot {
        try await postJSON(
            "finance/accounting-records/\(id.uuidString)/status",
            body: ["status": status.rawValue, "actor": actor],
            as: FinanceWorkspaceSnapshot.self
        )
    }

    func completeComplianceTask(id: UUID, actor: String) async throws -> FinanceWorkspaceSnapshot {
        try await postJSON(
            "finance/compliance-tasks/\(id.uuidString)/complete",
            body: ["actor": actor],
            as: FinanceWorkspaceSnapshot.self
        )
    }

    func captureGovernanceApprovalNote(id: UUID, actor: String) async throws -> FinanceWorkspaceSnapshot {
        try await postJSON(
            "finance/governance-events/\(id.uuidString)/approval-note",
            body: ["actor": actor],
            as: FinanceWorkspaceSnapshot.self
        )
    }

    func generateFinanceReport(period: String, actor: String) async throws -> GeneratedReportResponse {
        try await postJSON(
            "finance/reports/generate",
            body: ["period": period, "actor": actor],
            as: GeneratedReportResponse.self
        )
    }

    private func get<T: Decodable>(_ path: String, as type: T.Type) async throws -> T {
        let url = baseURL.appendingPathComponent(path)
        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        return try await decode(req, as: type)
    }

    private func postJSON<T: Decodable>(_ path: String, body: [String: String], as type: T.Type) async throws -> T {
        let url = baseURL.appendingPathComponent(path)
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try JSONSerialization.data(withJSONObject: body)
        return try await decode(req, as: type)
    }

    private func decode<T: Decodable>(_ req: URLRequest, as type: T.Type) async throws -> T {
        let (data, response) = try await http.data(for: req)
        guard let http = response as? HTTPURLResponse, (200 ..< 300).contains(http.statusCode) else {
            throw APIError.badStatus((response as? HTTPURLResponse)?.statusCode ?? -1)
        }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(T.self, from: data)
    }
}

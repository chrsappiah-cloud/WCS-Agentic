//
//  PlatformOrchestratorClient.swift
//  WCS-Agentic
//

import Foundation

struct PlatformOrchestratorClient: PlatformOrchestrating {
    private let baseURL: URL
    private let http: URLSessionHTTPClient

    init(baseURL: URL? = nil, http: URLSessionHTTPClient = URLSessionHTTPClient()) {
        if let baseURL {
            self.baseURL = baseURL
        } else if let s = Bundle.main.object(forInfoDictionaryKey: "WCSOrchestratorBaseURL") as? String,
                  let u = URL(string: s)
        {
            self.baseURL = u
        } else {
            self.baseURL = URL(string: "http://127.0.0.1:3000")!
        }
        self.http = http
    }

    func health() async throws -> OrchestratorHealth {
        try await get("health", as: OrchestratorHealth.self)
    }

    func setKillSwitch(enabled: Bool) async throws -> OrchestratorHealth {
        try await postJSON(path: "admin/kill-switch", json: ["enabled": enabled], as: OrchestratorHealth.self)
    }

    func startOnboarding(
        participantEmail: String,
        documentHint: String,
        fullName: String?,
        role: String
    ) async throws -> WorkflowStartResponse {
        var body: [String: String] = [
            "participantEmail": participantEmail,
            "documentHint": documentHint,
            "role": role,
        ]
        if let fullName { body["fullName"] = fullName }
        return try await post("v1/workflows/onboarding/start", body: body, as: WorkflowStartResponse.self)
    }

    func startCertificate(participantId: UUID, courseId: String, role: String) async throws -> WorkflowStartResponse {
        try await post(
            "v1/workflows/certificate/start",
            body: [
                "participantId": participantId.uuidString,
                "courseId": courseId,
                "role": role,
            ],
            as: WorkflowStartResponse.self
        )
    }

    func startConcierge(participantId: UUID, role: String) async throws -> WorkflowStartResponse {
        try await post(
            "v1/workflows/concierge/start",
            body: ["participantId": participantId.uuidString, "role": role],
            as: WorkflowStartResponse.self
        )
    }

    func fetchSession(id: String) async throws -> WorkflowSessionDTO {
        try await get("v1/sessions/\(id)", as: WorkflowSessionDTO.self)
    }

    func listPendingApprovals() async throws -> [ApprovalItemDTO] {
        let res: ApprovalsListResponse = try await get("v1/approvals", as: ApprovalsListResponse.self)
        return res.items
    }

    func approve(id: String, approvedBy: String) async throws {
        _ = try await postEmpty("v1/approvals/\(id)/approve", body: ["approvedBy": approvedBy])
    }

    func deny(id: String, reason: String) async throws {
        _ = try await postEmpty("v1/approvals/\(id)/deny", body: ["reason": reason])
    }

    func fetchAudit(limit: Int) async throws -> [AuditEventDTO] {
        let res: AuditLogResponse = try await get("v1/audit", as: AuditLogResponse.self)
        return Array(res.events.suffix(limit))
    }

    private func makeURL(path: String) throws -> URL {
        guard let url = URL(string: path, relativeTo: baseURL) else { throw PlatformError.invalidURL }
        return url
    }

    private func get<T: Decodable>(_ path: String, as type: T.Type) async throws -> T {
        var req = URLRequest(url: try makeURL(path: path))
        req.httpMethod = "GET"
        return try await decode(req, as: type)
    }

    private func post<T: Decodable>(_ path: String, body: [String: String], as type: T.Type) async throws -> T {
        var req = URLRequest(url: try makeURL(path: path))
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try JSONSerialization.data(withJSONObject: body)
        return try await decode(req, as: type)
    }

    private func postJSON<T: Decodable>(path: String, json: [String: Any], as type: T.Type) async throws -> T {
        var req = URLRequest(url: try makeURL(path: path))
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try JSONSerialization.data(withJSONObject: json)
        return try await decode(req, as: type)
    }

    private func postEmpty(_ path: String, body: [String: String]) async throws {
        var req = URLRequest(url: try makeURL(path: path))
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try JSONSerialization.data(withJSONObject: body)
        let (_, response) = try await http.data(for: req)
        guard let http = response as? HTTPURLResponse, (200 ..< 300).contains(http.statusCode) else {
            throw PlatformError.badStatus((response as? HTTPURLResponse)?.statusCode ?? -1)
        }
    }

    private func decode<T: Decodable>(_ req: URLRequest, as type: T.Type) async throws -> T {
        let (data, response) = try await http.data(for: req)
        guard let http = response as? HTTPURLResponse else { throw PlatformError.badStatus(-1) }
        if http.statusCode == 503,
           let err = try? JSONDecoder().decode([String: String].self, from: data),
           err["error"] == "kill_switch_active"
        {
            throw PlatformError.killSwitchActive
        }
        guard (200 ..< 300).contains(http.statusCode) else {
            throw PlatformError.badStatus(http.statusCode)
        }
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw PlatformError.decoding
        }
    }
}

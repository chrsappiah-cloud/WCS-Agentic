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
}

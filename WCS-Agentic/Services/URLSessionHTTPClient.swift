//
//  URLSessionHTTPClient.swift
//  WCS-Agentic
//

import Foundation

/// Thin async HTTP layer used by `VaporBackendClient`, with injectable middleware.
struct URLSessionHTTPClient: Sendable {
    private let session: URLSession
    private let middleware: [any HTTPRequestMiddleware]

    init(session: URLSession = .shared, middleware: [any HTTPRequestMiddleware] = [LoggingHTTPMiddleware(label: "WCS")]) {
        self.session = session
        self.middleware = middleware
    }

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        var req = request
        for m in middleware {
            req = m.prepare(req)
        }
        do {
            let (data, response) = try await session.data(for: req)
            for m in middleware {
                m.didReceive(response: response, data: data, error: nil)
            }
            return (data, response)
        } catch {
            for m in middleware {
                m.didReceive(response: nil, data: nil, error: error)
            }
            throw error
        }
    }
}

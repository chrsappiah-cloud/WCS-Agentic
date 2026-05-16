//
//  HTTPRequestMiddleware.swift
//  WCS-Agentic
//

import Foundation

/// Composable request pipeline (logging, headers, retries) in front of `URLSession`.
protocol HTTPRequestMiddleware: Sendable {
    func prepare(_ request: URLRequest) -> URLRequest
    func didReceive(response: URLResponse?, data: Data?, error: Error?)
}

struct LoggingHTTPMiddleware: HTTPRequestMiddleware {
    let label: String

    func prepare(_ request: URLRequest) -> URLRequest {
        #if DEBUG
        print("[\(label)] → \(request.httpMethod ?? "?") \(request.url?.absoluteString ?? "")")
        #endif
        return request
    }

    func didReceive(response: URLResponse?, data: Data?, error: Error?) {
        #if DEBUG
        if let http = response as? HTTPURLResponse {
            print("[\(label)] ← \(http.statusCode) bytes=\(data?.count ?? 0)")
        } else if let error {
            print("[\(label)] ✗ \(error.localizedDescription)")
        }
        #endif
    }
}

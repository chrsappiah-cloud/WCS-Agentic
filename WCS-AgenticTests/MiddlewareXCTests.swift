//
//  MiddlewareXCTests.swift
//  WCS-AgenticTests
//

import XCTest
@testable import WCS_Agentic

final class MiddlewareXCTests: XCTestCase {
    func testLoggingMiddlewarePreparePreservesURL() {
        let m = LoggingHTTPMiddleware(label: "test")
        var req = URLRequest(url: URL(string: "https://example.com/ping")!)
        req.httpMethod = "GET"
        let out = m.prepare(req)
        XCTAssertEqual(out.url?.host, "example.com")
    }
}

//
//  WCS_AgenticTests.swift
//  WCS-AgenticTests
//

import Foundation
import Testing
@testable import WCS_Agentic

struct WCS_AgenticTests {
    @Test func middlewareDoesNotStripMethod() async throws {
        let m = LoggingHTTPMiddleware(label: "t")
        var r = URLRequest(url: URL(string: "https://example.com")!)
        r.httpMethod = "POST"
        let o = m.prepare(r)
        #expect(o.httpMethod == "POST")
    }
}

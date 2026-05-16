//
//  MonitoringEventRecord.swift
//  WCS-Agentic
//

import Foundation
import SwiftData

enum MonitoringSeverity: String, Codable, CaseIterable, Sendable {
    case info
    case warning
    case critical

    var systemImage: String {
        switch self {
        case .info: "info.circle"
        case .warning: "exclamationmark.triangle"
        case .critical: "bolt.trianglebadge.exclamationmark"
        }
    }
}

@Model
final class MonitoringEventRecord {
    @Attribute(.unique) var id: UUID
    var source: String
    var message: String
    var severityRaw: String
    var createdAt: Date

    var severity: MonitoringSeverity {
        get { MonitoringSeverity(rawValue: severityRaw) ?? .info }
        set { severityRaw = newValue.rawValue }
    }

    init(
        id: UUID = UUID(),
        source: String,
        message: String,
        severity: MonitoringSeverity = .info,
        createdAt: Date = .now
    ) {
        self.id = id
        self.source = source
        self.message = message
        self.severityRaw = severity.rawValue
        self.createdAt = createdAt
    }
}

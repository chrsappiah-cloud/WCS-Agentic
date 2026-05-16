//
//  AgenticDesignSystem.swift
//  WCS-Agentic
//

import SwiftUI

/// Visual language inspired by leading “agentic” productivity apps: calm surfaces, crisp hierarchy, and confident accents.
enum AgenticTheme {
    static let emerald = Color(red: 0.09, green: 0.55, blue: 0.45)
    static let bronze = Color(red: 0.72, green: 0.52, blue: 0.32)
    static let ink = Color(red: 0.07, green: 0.09, blue: 0.12)
    static let mist = Color.white.opacity(0.72)

    static let heroGradient = LinearGradient(
        colors: [
            emerald.opacity(0.95),
            Color(red: 0.05, green: 0.18, blue: 0.16),
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let pageBackground = LinearGradient(
        colors: [
            Color(.systemGroupedBackground),
            Color(.secondarySystemGroupedBackground),
        ],
        startPoint: .top,
        endPoint: .bottom
    )
}

struct GlassCard<Content: View>: View {
    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(.ultraThinMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .strokeBorder(Color.primary.opacity(0.06), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.08), radius: 18, y: 10)
    }
}

struct HealthStatusPill: View {
    let text: String

    private var isHealthy: Bool {
        let t = text.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return t == "ok" || t.contains("healthy") || t.contains("alive")
    }

    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(isHealthy ? Color.green : Color.orange)
                .frame(width: 8, height: 8)
                .accessibilityHidden(true)
            Text(text)
                .font(.headline.monospaced())
                .foregroundStyle(.primary)
                .lineLimit(2)
                .minimumScaleFactor(0.75)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            Capsule(style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        )
        .overlay(
            Capsule(style: .continuous)
                .strokeBorder(Color.primary.opacity(0.08), lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
    }
}

struct AgenticHeroHeader: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline, spacing: 10) {
                Image(systemName: "sparkles")
                    .font(.title2.weight(.semibold))
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(AgenticTheme.mist, AgenticTheme.bronze.opacity(0.95))
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(.white)
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.86))
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AgenticTheme.heroGradient)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.18), radius: 22, y: 14)
    }
}

import Fluent
import FluentSQLiteDriver
import JWT
import Vapor

/// In-memory SQLite wiring for `swift test` (no Docker/Postgres required).
enum TestingConfiguration {
    static func configure(_ app: Application) throws {
        app.http.server.configuration.hostname = "127.0.0.1"
        app.http.server.configuration.port = 0

        app.databases.use(.sqlite(.memory), as: .sqlite)
        app.migrations.add(CreateParticipantMigration())
        app.migrations.add(CreateWorkflowRunMigration())

        let jwtSecret = "test-secret"
        app.jwt.signers.use(.hs256(key: jwtSecret), kid: "wcs")

        try routes(app)
    }
}

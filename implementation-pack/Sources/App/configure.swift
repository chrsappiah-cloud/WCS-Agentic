import Fluent
import FluentPostgresDriver
import JWT
import Vapor

func configure(_ app: Application) throws {
    app.http.server.configuration.hostname = "0.0.0.0"
    app.http.server.configuration.port = Environment.get("PORT").flatMap { Int($0) } ?? 8080

    let dbHost = Environment.get("DB_HOST") ?? "localhost"
    let dbPort = Environment.get("DB_PORT").flatMap { Int($0) } ?? SQLPostgresConfiguration.ianaPortNumber
    let dbUser = Environment.get("DB_USER") ?? "postgres"
    let dbPassword = Environment.get("DB_PASSWORD") ?? "postgres"
    let dbName = Environment.get("DB_NAME") ?? "wcs"

    let sqlConfig = SQLPostgresConfiguration(
        hostname: dbHost,
        port: dbPort,
        username: dbUser,
        password: dbPassword,
        database: dbName,
        tls: .disable
    )

    app.databases.use(DatabaseConfigurationFactory.postgres(configuration: sqlConfig), as: .psql)

    app.migrations.add(CreateParticipantMigration())
    app.migrations.add(CreateWorkflowRunMigration())

    let jwtSecret = Environment.get("JWT_SECRET") ?? "development-only-change-me"
    app.jwt.signers.use(.hs256(key: jwtSecret), kid: "wcs")

    try routes(app)
}

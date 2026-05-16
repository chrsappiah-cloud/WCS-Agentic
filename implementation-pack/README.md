# WCS Agentic SaaS Starter

Swift-first backend using Vapor for World Class Scholars.

## Run locally

```bash
cd implementation-pack
docker compose up --build
```

## Endpoints

- `POST /participants` — JSON `{ "email", "fullName" }`; creates participant and onboarding workflow run
- `POST /identity/upload` — JSON `{ "participantID", "documentURL" }`
- `POST /workflows/approve` — JSON `{ "workflowID", "approvedBy" }`
- `GET /health`

## Native run (requires Postgres)

```bash
export DB_HOST=127.0.0.1
export DB_USER=postgres
export DB_PASSWORD=postgres
export DB_NAME=wcs
swift run App
```

## Docker image

The image uses `swift:6.0-jammy` and starts the server with:

`App serve --hostname 0.0.0.0 --port 8080`

## Note on `Package.swift` platforms

`platforms: [.macOS(.v13)]` sets the **minimum macOS** for Apple toolchains. If `docker compose build` fails on Linux with a platform error, remove the `platforms` line for Linux-only CI images.

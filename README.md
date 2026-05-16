# WCS-Agentic

World Class Scholars — agentic operations platform: **iOS client**, **Vapor API**, **Node orchestrator**, **Python workers**, governance UI, and playbook.

## Repository map

| Path | Description |
|------|-------------|
| [`WCS-Agentic/`](WCS-Agentic/) | SwiftUI + SwiftData iOS app (Programs, Agents, Monitor, Account, Admin) |
| [`implementation-pack/`](implementation-pack/) | Vapor/Fluent API + Docker |
| [`platform/`](platform/) | Orchestrator, workers, OPA policies, governance UI, Compose |
| [`docs/playbook/`](docs/playbook/) | **Agentic AI Playbook** (Exploring → Implementing → Scaling) |
| [`docs/production-operating-manual/`](docs/production-operating-manual/) | **Production manual** — case-study map + 4 workflow playbooks |
| [`docs/TESTFLIGHT.md`](docs/TESTFLIGHT.md) | TestFlight upload checklist |

## Quick start (full stack)

```bash
# Terminal 1 — platform (orchestrator, worker, OPA, Vapor, UI)
cd platform && docker compose up --build

# Terminal 2 — iOS (Xcode) — set WCSAPIBaseURL to http://127.0.0.1:8080
open WCS-Agentic.xcodeproj
```

**Governance UI:** http://localhost:5173 · **Orchestrator:** http://localhost:3000

## Tests

```bash
SKIP_UI_TESTS=1 ./scripts/run-ios-tests.sh
cd implementation-pack && swift test
cd platform/orchestrator && npm test
```

## TestFlight

See [docs/TESTFLIGHT.md](docs/TESTFLIGHT.md) — App ID `6769985809`.

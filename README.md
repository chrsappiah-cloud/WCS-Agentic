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
| [`docs/governance/`](docs/governance/) | **Founder governance pack** — controlled WCS charters, policies, contracts, finance models |
| [`docs/TESTFLIGHT.md`](docs/TESTFLIGHT.md) | TestFlight upload checklist |

## Quick start (full stack)

```bash
# Terminal 1 — platform (orchestrator, worker, OPA, Vapor, UI)
cd platform && docker compose up --build

# Terminal 2 — iOS (Xcode) — set WCSAPIBaseURL to http://127.0.0.1:8080
open WCS-Agentic.xcodeproj
```

**Governance UI:** http://localhost:5173 · **Orchestrator:** http://localhost:3000

## Tests & CI/CD

```bash
./scripts/run-all-tests.sh          # local: all suites
./scripts/build-install-test-ios.sh # build + install simulator + XCTest
```

| Workflow | Trigger | Purpose |
|----------|---------|---------|
| [CI](.github/workflows/ci.yml) | push/PR `main` | **Required gate** — XCTest, Vapor, orchestrator, Python |
| [CD TestFlight](.github/workflows/cd-testflight.yml) | manual / `v*` tag | Archive + App Store Connect upload |

Enable **CI gate (required)** on `main` — see [.github/BRANCH_PROTECTION.md](.github/BRANCH_PROTECTION.md).

## PDF implementation pack

Board-ready PDFs (operating manual + Swift sources): [`docs/pdf/`](docs/pdf/)

```bash
.venv-pdf/bin/python scripts/generate_implementation_pack_pdf.py
```

## Founder governance pack

The founder documentation pack has been materialized as controlled Markdown files under [`docs/governance/`](docs/governance/). Refresh it with:

```bash
python3 scripts/materialize_founder_governance_pack.py
```

## TestFlight

```bash
./scripts/validate-testflight.sh
./scripts/prepare-testflight.sh
```

See [testflight/](testflight/) and [docs/TESTFLIGHT.md](docs/TESTFLIGHT.md) — App ID `6769985809`.

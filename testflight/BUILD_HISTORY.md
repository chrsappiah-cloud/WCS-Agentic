# TestFlight build history

| Version | Build | Date | Commit | Notes |
|---------|-------|------|--------|-------|
| 1.1 | 4 | 2026-05-16 | `3ebe1a3` | Orchestrator integration, Approvals tab, full CI |
| 1.1 | 5 | 2026-05-16 | `4efe84a` | TestFlight folder, validate script, QA checklist |
| 1.1 | 5 | 2026-05-16 | `4e78986` | XCTest fixes, build-install-test-ios script |
| 1.1 | 6 | 2026-05-16 | (this release) | Enforced CI/CD gate, full XCTest in CI, production upload |

**Production identifiers**

| Field | Value |
|-------|--------|
| Bundle ID | `wcs.WCS-Agentic` |
| Team ID | `TM2WG7HH96` |
| ASC App ID | `6769985809` |
| IAP | `wcs.agentic.pro.monthly` |
| Push | `aps-environment` = `production` |

**Commands**

```bash
./scripts/validate-testflight.sh
./scripts/run-all-tests.sh
./scripts/prepare-testflight.sh
```

**ASC:** https://appstoreconnect.apple.com/teams/70c46c69-5d6d-438d-b300-31df2b93163a/apps/6769985809/testflight

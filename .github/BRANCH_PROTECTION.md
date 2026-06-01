# Branch protection (recommended)

On GitHub → **Settings → Branches → Add rule** for `main`:

| Setting | Value |
|---------|--------|
| Require status checks | **CI gate (required)** |
| Also require | `iOS unit tests (XCTest)`, `Vapor API`, `Node orchestrator`, `Python worker` |
| Require branches up to date | Yes |
| Require pull request reviews | Optional (team policy) |

Workflows:

- **CI** (`.github/workflows/ci.yml`) — every push/PR; must pass before merge.
- **CD TestFlight** (`.github/workflows/cd-testflight.yml`) — manual dispatch or `v*` tag; uploads to App Store Connect (requires Mac runner + Xcode signing).

Local release:

```bash
./scripts/validate-testflight.sh
./scripts/run-all-tests.sh
./scripts/prepare-testflight.sh
```

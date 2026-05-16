# TestFlight release checklist — WCS-Agentic

**Canonical TestFlight folder:** [`testflight/`](../testflight/) (export plist, QA checklist, build history)

**App Store Connect:** [TestFlight for WCS-Agentic](https://appstoreconnect.apple.com/teams/70c46c69-5d6d-438d-b300-31df2b93163a/apps/6769985809/testflight)  
**Apple App ID:** `6769985809` · **Bundle ID:** `wcs.WCS-Agentic` · **Team:** `TM2WG7HH96`

## Release pipeline

```bash
cd /Applications/WCS-Agentic
./scripts/validate-testflight.sh    # entitlements, StoreKit, version
./scripts/run-all-tests.sh          # iOS + Vapor + orchestrator + Python
./scripts/prepare-testflight.sh     # archive + upload (or --archive-only)
```

See [testflight/QA_CHECKLIST.md](../testflight/QA_CHECKLIST.md) for per-build QA and [testflight/BUILD_HISTORY.md](../testflight/BUILD_HISTORY.md) for upload log.

## App Store Connect (one-time)

1. App **WCS-Agentic** with bundle ID `wcs.WCS-Agentic` (team `TM2WG7HH96`).
2. **In-App Purchases** enabled for the bundle ID.
3. Subscription **`wcs.agentic.pro.monthly`** (auto-renewable, group “WCS Agentic Pro”).
4. Optional **1-week free trial** (mirrored in `WCS-Agentic/Configuration/Products.storekit`).

## Local subscription testing

- Scheme **WCS-Agentic** → `Configuration/Products.storekit`
- Simulator → **Account** → Load product → Subscribe (sandbox)

## Sandbox testers

1. ASC → **Users and Access** → **Sandbox** → create testers.
2. Device → Settings → App Store → Sandbox Account.
3. Install from TestFlight; IAP uses sandbox billing.

## Manual upload (if CLI fails)

1. Archive: `./scripts/prepare-testflight.sh --archive-only`
2. Xcode → **Window → Organizer → Archives** → `build/WCS-Agentic.xcarchive`
3. **Distribute App** → **App Store Connect** → **Upload**

Export options: [testflight/ExportOptions.plist](../testflight/ExportOptions.plist)

## QA accounts

| Account | Email | Role | Subscription |
|---------|-------|------|----------------|
| Admin | `admin@worldclassscholars.test` | Admin | Pro (seeded) |
| Operator | `operator@worldclassscholars.test` | Operator | Grant Pro in Admin or IAP |
| Demo user | `demo@worldclassscholars.test` | User | Free |

**Account → Quick sign-in (demo admin)** for internal QA.

## What to verify (summary)

- **Programs** — enroll, mock ID upload (Vapor)
- **Agents** — onboarding / certificate / concierge (orchestrator; LAN optional)
- **Approvals** — queue approve/deny
- **Monitor** — dual API health + audit
- **Account** — StoreKit purchase + restore
- **Admin** — kill-switch, roles, tiers

### LAN E2E (optional)

```bash
cd platform && docker compose up --build
```

Set device `WCSAPIBaseURL` / `WCSOrchestratorBaseURL` to Mac LAN IP (`:8080` / `:3000`).

## Entitlements

Production entitlements: **push only** (`aps-environment` = `production`). Do not add unused CloudKit/iCloud keys — they break ASC upload.

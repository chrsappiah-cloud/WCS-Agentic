# TestFlight release checklist — WCS-Agentic

**App Store Connect:** [TestFlight for WCS-Agentic](https://appstoreconnect.apple.com/teams/70c46c69-5d6d-438d-b300-31df2b93163a/apps/6769985809/testflight)  
**Apple App ID:** `6769985809` · **Bundle ID:** `wcs.WCS-Agentic` · **Team:** `TM2WG7HH96`

## App Store Connect (one-time)

1. Create app **WCS-Agentic** with bundle ID `wcs.WCS-Agentic` (team `TM2WG7HH96`).
2. Enable **In-App Purchases** for the bundle ID.
3. Create subscription product **`wcs.agentic.pro.monthly`** (auto-renewable, group “WCS Agentic Pro”).
4. Add a **1-week free trial** introductory offer (optional; mirrored in `Configuration/Products.storekit` for local testing).

## Local subscription testing

- Scheme **WCS-Agentic** uses `WCS-Agentic/Configuration/Products.storekit` (StoreKit Testing).
- Run on simulator → **Account** tab → **Load subscription product** → **Subscribe to Pro (sandbox)**.

## Sandbox testers (TestFlight)

1. App Store Connect → **Users and Access** → **Sandbox** → create tester Apple IDs.
2. On device: Settings → App Store → Sandbox Account → sign in with sandbox tester.
3. Install build from TestFlight; purchases use sandbox billing (no real charges).

## Build & upload

```bash
cd /Applications/WCS-Agentic
./scripts/prepare-testflight.sh
```

If CLI export fails with *Error Downloading App Information*, upload from Xcode:

1. Open **Window → Organizer → Archives** (archive is at `build/WCS-Agentic.xcarchive` after a successful archive).
2. **Distribute App** → **App Store Connect** → **Upload**.
3. Wait for processing, then enable **TestFlight** internal/external testing.

## Roles for QA

| Account | Email | Role | Subscription |
|---------|-------|------|----------------|
| Admin | `admin@worldclassscholars.test` | Admin | Pro (seeded) |
| Operator | `operator@worldclassscholars.test` | Operator | Free (grant Pro in Admin or IAP) |
| Demo user | `demo@worldclassscholars.test` | User | Free |

Use **Account → Quick sign-in (demo admin)** for internal QA, or sign in with any email to create a user row.

## What to verify on TestFlight

- **Programs**: enroll sample participant; submit mock identity document (Vapor API).
- **Agents**: start **onboarding**, **certificate**, or **concierge** orchestrator workflow (requires platform at `WCSOrchestratorBaseURL` for live runs; mocks work offline in UI tests only).
- **Approvals**: approve/deny queued orchestrator items (pair with `docker compose up` in `platform/` for full E2E on LAN).
- **Monitor**: Vapor + orchestrator health; platform audit sync.
- **Account**: StoreKit purchase + restore.
- **Admin**: kill-switch toggle, role/tier/access changes.

### LAN E2E (optional, same Wi‑Fi as Mac)

```bash
cd platform && docker compose up --build
```

Point device `WCSAPIBaseURL` / `WCSOrchestratorBaseURL` to your Mac’s LAN IP (e.g. `http://192.168.1.x:8080` and `:3000`).

# TestFlight release checklist — WCS-Agentic

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

- **Agents**: run a supervised workflow with Pro/Operator access.
- **Monitor**: API health + event stream after agent runs.
- **Account**: StoreKit purchase + restore.
- **Admin**: change role, subscription tier, and access enabled flag.

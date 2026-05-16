# TestFlight — WCS-Agentic

Release assets and checklists for App Store Connect TestFlight distribution.

| Resource | Path |
|----------|------|
| Full checklist & ASC links | [docs/TESTFLIGHT.md](../docs/TESTFLIGHT.md) |
| Export options (App Store upload) | [ExportOptions.plist](ExportOptions.plist) |
| QA checklist (per build) | [QA_CHECKLIST.md](QA_CHECKLIST.md) |
| Build history | [BUILD_HISTORY.md](BUILD_HISTORY.md) |
| Archive & upload script | [../scripts/prepare-testflight.sh](../scripts/prepare-testflight.sh) |
| Validate before upload | [../scripts/validate-testflight.sh](../scripts/validate-testflight.sh) |

## Quick release

```bash
cd /Applications/WCS-Agentic
./scripts/validate-testflight.sh   # preflight
./scripts/run-all-tests.sh         # all unit suites
./scripts/prepare-testflight.sh    # archive + upload
```

## App Store Connect

- **TestFlight:** https://appstoreconnect.apple.com/teams/70c46c69-5d6d-438d-b300-31df2b93163a/apps/6769985809/testflight
- **Bundle ID:** `wcs.WCS-Agentic`
- **Team ID:** `TM2WG7HH96`
- **IAP:** `wcs.agentic.pro.monthly`

## Local artifacts (gitignored)

After `prepare-testflight.sh`:

- `build/WCS-Agentic.xcarchive`
- `build/TestFlightExport/WCS-Agentic.ipa`

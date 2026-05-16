#!/usr/bin/env bash
# Archive WCS-Agentic and upload to App Store Connect (TestFlight).
#
# Prerequisites:
#   - Xcode signed in with Apple ID (team TM2WG7HH96)
#   - App record + IAP `wcs.agentic.pro.monthly` in App Store Connect
#
# Usage:
#   ./scripts/prepare-testflight.sh              # tests + archive + upload
#   ./scripts/prepare-testflight.sh --skip-tests
#   ./scripts/prepare-testflight.sh --archive-only

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

SCHEME="WCS-Agentic"
ARCHIVE_PATH="$ROOT/build/WCS-Agentic.xcarchive"
EXPORT_PATH="$ROOT/build/TestFlightExport"
EXPORT_PLIST="$ROOT/testflight/ExportOptions.plist"
SKIP_TESTS=0
ARCHIVE_ONLY=0

for arg in "$@"; do
  case "$arg" in
    --skip-tests) SKIP_TESTS=1 ;;
    --archive-only) ARCHIVE_ONLY=1 ;;
    -h|--help)
      echo "Usage: $0 [--skip-tests] [--archive-only]"
      exit 0
      ;;
    *) echo "Unknown option: $arg" >&2; exit 1 ;;
  esac
done

[[ -f "$EXPORT_PLIST" ]] || { echo "Missing $EXPORT_PLIST" >&2; exit 1; }

if [[ "$SKIP_TESTS" -eq 0 ]]; then
  echo "==> Preflight"
  chmod +x scripts/validate-testflight.sh scripts/run-all-tests.sh
  ./scripts/validate-testflight.sh
  echo "==> Running all unit tests"
  ./scripts/run-all-tests.sh
fi

mkdir -p build

MARKETING=$(grep -m1 'MARKETING_VERSION' WCS-Agentic.xcodeproj/project.pbxproj | sed 's/.*= \(.*\);/\1/')
BUILD=$(grep -m1 'CURRENT_PROJECT_VERSION' WCS-Agentic.xcodeproj/project.pbxproj | sed 's/.*= \(.*\);/\1/')
echo "==> Archiving $SCHEME $MARKETING ($BUILD) Release…"

xcodebuild \
  -scheme "$SCHEME" \
  -configuration Release \
  -destination 'generic/platform=iOS' \
  -archivePath "$ARCHIVE_PATH" \
  -allowProvisioningUpdates \
  archive

if [[ "$ARCHIVE_ONLY" -eq 1 ]]; then
  echo ""
  echo "Archive only: $ARCHIVE_PATH"
  echo "Upload manually via Xcode Organizer or re-run without --archive-only"
  exit 0
fi

echo "==> Exporting and uploading to App Store Connect…"
rm -rf "$EXPORT_PATH"
xcodebuild -exportArchive \
  -archivePath "$ARCHIVE_PATH" \
  -exportPath "$EXPORT_PATH" \
  -exportOptionsPlist "$EXPORT_PLIST" \
  -allowProvisioningUpdates

COMMIT=$(git rev-parse --short HEAD 2>/dev/null || echo "local")
DATE=$(date +%Y-%m-%d)
echo ""
echo "==> Upload complete"
echo "    Version: $MARKETING ($BUILD)"
echo "    Archive: $ARCHIVE_PATH"
echo "    Export:  $EXPORT_PATH"
echo "    Commit:  $COMMIT"
echo ""
echo "Next: App Store Connect → TestFlight → enable testing when processing finishes."
echo "      https://appstoreconnect.apple.com/teams/70c46c69-5d6d-438d-b300-31df2b93163a/apps/6769985809/testflight"
echo ""
echo "Update testflight/BUILD_HISTORY.md with build $BUILD ($DATE, $COMMIT)."

#!/usr/bin/env bash
# Archive WCS-Agentic for TestFlight upload via Xcode Organizer or altool.
#
# Prerequisites:
#   - Xcode signed in with Apple ID (team TM2WG7HH96)
#   - App record + IAP product `wcs.agentic.pro.monthly` in App Store Connect
#   - In-App Purchase capability enabled for bundle id wcs.WCS-Agentic
#
# Usage:
#   ./scripts/prepare-testflight.sh
#   open build/export  # after successful export

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

SCHEME="WCS-Agentic"
ARCHIVE_PATH="$ROOT/build/WCS-Agentic.xcarchive"
EXPORT_PATH="$ROOT/build/TestFlightExport"
EXPORT_PLIST="$ROOT/scripts/ExportOptions.plist"

mkdir -p build

echo "==> Archiving $SCHEME (Release, generic iOS)…"
xcodebuild \
  -scheme "$SCHEME" \
  -configuration Release \
  -destination 'generic/platform=iOS' \
  -archivePath "$ARCHIVE_PATH" \
  archive

if [[ ! -f "$EXPORT_PLIST" ]]; then
  cat > "$EXPORT_PLIST" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>method</key>
	<string>app-store-connect</string>
	<key>destination</key>
	<string>upload</string>
	<key>signingStyle</key>
	<string>automatic</string>
	<key>uploadSymbols</key>
	<true/>
</dict>
</plist>
PLIST
fi

echo "==> Exporting for App Store Connect…"
rm -rf "$EXPORT_PATH"
xcodebuild -exportArchive \
  -archivePath "$ARCHIVE_PATH" \
  -exportPath "$EXPORT_PATH" \
  -exportOptionsPlist "$EXPORT_PLIST"

echo ""
echo "Archive: $ARCHIVE_PATH"
echo "Export:  $EXPORT_PATH"
echo ""
echo "Next: open Xcode → Window → Organizer → Archives, or upload the .ipa from $EXPORT_PATH"
echo "Enable Sandbox testers in App Store Connect → TestFlight for subscription testing."

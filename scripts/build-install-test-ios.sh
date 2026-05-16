#!/usr/bin/env bash
# Build, install on simulator, and run all XCTest targets (unit + UI).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

DEVICE_NAME="${WCS_SIM_DEVICE_NAME:-WCS-Agentic Test}"
SIM_UDID="$(xcrun simctl list devices 2>/dev/null | grep -F "$DEVICE_NAME" | sed -n 's/.*(\([A-F0-9-]\{36\}\)).*/\1/p' | head -1)"
if [[ -z "$SIM_UDID" ]]; then
  echo "Simulator '$DEVICE_NAME' not found. Run ./scripts/run-ios-tests.sh once to create it." >&2
  exit 2
fi

echo "==> Boot simulator $DEVICE_NAME ($SIM_UDID)"
xcrun simctl boot "$SIM_UDID" 2>/dev/null || true
xcrun simctl bootstatus "$SIM_UDID" -b >/dev/null

echo "==> Build Debug"
xcodebuild -scheme WCS-Agentic \
  -configuration Debug \
  -destination "platform=iOS Simulator,id=$SIM_UDID" \
  build | tail -5

APP="$(find ~/Library/Developer/Xcode/DerivedData -name 'WCS-Agentic.app' -path '*Debug-iphonesimulator*' -not -path '*Index*' 2>/dev/null | head -1)"
[[ -n "$APP" ]] || { echo "Could not find WCS-Agentic.app" >&2; exit 1; }

VER=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$APP/Info.plist")
BUILD=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleVersion' "$APP/Info.plist")
echo "==> Install $VER ($BUILD)"
xcrun simctl install "$SIM_UDID" "$APP"
xcrun simctl launch "$SIM_UDID" wcs.WCS-Agentic || true

echo "==> Run all XCTest (unit + UI)"
WCS_SIM_DEVICE_NAME="$DEVICE_NAME" ./scripts/run-ios-tests.sh

echo "==> Backend / platform unit tests"
./scripts/run-all-tests.sh

echo ""
echo "Done: app $VER ($BUILD) installed on $DEVICE_NAME; all tests passed."

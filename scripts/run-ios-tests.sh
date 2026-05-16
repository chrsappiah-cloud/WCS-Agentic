#!/usr/bin/env bash
# Run WCS-Agentic scheme tests on an iOS Simulator (creates/boots device as needed).
# Usage:
#   ./scripts/run-ios-tests.sh              # all tests (unit + UI)
#   SKIP_UI_TESTS=1 ./scripts/run-ios-tests.sh   # unit tests only (faster CI)
#
# Optional env:
#   WCS_SIM_DEVICE_NAME   default: WCS-Agentic Test
#   WCS_SIM_RUNTIME       override simulator runtime bundle id
#   WCS_SIM_DEVICE_TYPE   override device type bundle id
#   WCS_SERIAL_TESTS      default 1 → -parallel-testing-enabled NO

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

DEVICE_NAME="${WCS_SIM_DEVICE_NAME:-WCS-Agentic Test}"

pick_runtime_id() {
  if [[ -n "${WCS_SIM_RUNTIME:-}" ]]; then
    echo "$WCS_SIM_RUNTIME"
    return
  fi
  # Prefer the last listed available iOS runtime (newest on typical Xcode installs).
  xcrun simctl list runtimes available 2>/dev/null \
    | grep -E 'com\.apple\.CoreSimulator\.SimRuntime\.iOS-' \
    | tail -1 \
    | sed -n 's/.*\(com\.apple\.CoreSimulator\.SimRuntime\.iOS-[^[:space:]]*\).*/\1/p'
}

pick_device_type() {
  if [[ -n "${WCS_SIM_DEVICE_TYPE:-}" ]]; then
    echo "$WCS_SIM_DEVICE_TYPE"
    return
  fi
  # Prefer modern iPhone types that exist on both local Xcode 26 and GitHub Xcode 16 runners.
  for id in \
    com.apple.CoreSimulator.SimDeviceType.iPhone-16 \
    com.apple.CoreSimulator.SimDeviceType.iPhone-15 \
    com.apple.CoreSimulator.SimDeviceType.iPhone-17
  do
    if xcrun simctl list devicetypes 2>/dev/null | grep -q "$id"; then
      echo "$id"
      return
    fi
  done
  echo "com.apple.CoreSimulator.SimDeviceType.iPhone-15"
}

RUNTIME_ID="$(pick_runtime_id)"
if [[ -z "$RUNTIME_ID" ]]; then
  echo "ERROR: No available iOS simulator runtime found. Install an iOS runtime in Xcode (Settings → Platforms)." >&2
  exit 2
fi

DEVICE_TYPE="$(pick_device_type)"

udid_for_name() {
  xcrun simctl list devices available 2>/dev/null \
    | grep -F "$DEVICE_NAME" \
    | sed -n 's/.*(\([A-F0-9-]\{36\}\)).*/\1/p' \
    | head -1
}

SIM_UDID="$(udid_for_name || true)"
if [[ -z "$SIM_UDID" ]]; then
  echo "Creating simulator: $DEVICE_NAME (type=$DEVICE_TYPE runtime=$RUNTIME_ID)"
  SIM_UDID="$(xcrun simctl create "$DEVICE_NAME" "$DEVICE_TYPE" "$RUNTIME_ID")"
fi

echo "Using simulator $DEVICE_NAME ($SIM_UDID)"
xcrun simctl boot "$SIM_UDID" 2>/dev/null || true
xcrun simctl bootstatus "$SIM_UDID" -b >/dev/null

DEST="platform=iOS Simulator,id=$SIM_UDID"
XCODE_ARGS=( -scheme WCS-Agentic -destination "$DEST" )

if [[ "${SKIP_UI_TESTS:-}" == "1" ]]; then
  XCODE_ARGS+=( -skip-testing:WCS-AgenticUITests )
fi

if [[ "${WCS_SERIAL_TESTS:-1}" == "1" ]]; then
  XCODE_ARGS+=( -parallel-testing-enabled NO )
fi

set +e
xcodebuild "${XCODE_ARGS[@]}" test | tee /tmp/wcs-agentic-xcodebuild.log
STATUS=$?
set -e

if [[ "$STATUS" -ne 0 ]]; then
  echo "xcodebuild failed ($STATUS). Last 60 lines:"
  tail -60 /tmp/wcs-agentic-xcodebuild.log
  exit "$STATUS"
fi

echo "Tests finished successfully."

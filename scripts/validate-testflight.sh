#!/usr/bin/env bash
# Preflight checks before TestFlight archive/upload.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

fail() { echo "ERROR: $*" >&2; exit 1; }
warn() { echo "WARN: $*" >&2; }

echo "==> TestFlight preflight"

# Version / build from Xcode project
MARKETING=$(grep -m1 'MARKETING_VERSION' WCS-Agentic.xcodeproj/project.pbxproj | sed 's/.*= \(.*\);/\1/')
BUILD=$(grep -m1 'CURRENT_PROJECT_VERSION' WCS-Agentic.xcodeproj/project.pbxproj | sed 's/.*= \(.*\);/\1/')
echo "    Version: $MARKETING ($BUILD)"

[[ -f "$ROOT/testflight/ExportOptions.plist" ]] || fail "Missing testflight/ExportOptions.plist"
[[ -f "$ROOT/WCS-Agentic/WCS_Agentic.entitlements" ]] || fail "Missing entitlements"

if grep -q 'com.apple.developer.icloud' "$ROOT/WCS-Agentic/WCS_Agentic.entitlements" 2>/dev/null; then
  fail "Remove unused iCloud/CloudKit entitlements (causes ASC upload errors)"
fi

if ! grep -q 'aps-environment' "$ROOT/WCS-Agentic/WCS_Agentic.entitlements"; then
  warn "aps-environment not set in entitlements"
fi

[[ -f "$ROOT/WCS-Agentic/Configuration/Products.storekit" ]] || fail "Missing Products.storekit"
grep -q 'wcs.agentic.pro.monthly' "$ROOT/WCS-Agentic/Configuration/Products.storekit" \
  || fail "StoreKit config missing product wcs.agentic.pro.monthly"

grep -q 'WCSOrchestratorBaseURL' "$ROOT/WCS-Agentic/Info.plist" \
  || warn "WCSOrchestratorBaseURL not in Info.plist"

command -v xcodebuild >/dev/null || fail "xcodebuild not found"

echo "==> Scheme resolves"
xcodebuild -scheme WCS-Agentic -showBuildSettings -configuration Release 2>/dev/null \
  | grep -E 'PRODUCT_BUNDLE_IDENTIFIER|DEVELOPMENT_TEAM|MARKETING_VERSION|CURRENT_PROJECT_VERSION' \
  | head -6

echo ""
echo "Preflight OK — run ./scripts/run-all-tests.sh then ./scripts/prepare-testflight.sh"

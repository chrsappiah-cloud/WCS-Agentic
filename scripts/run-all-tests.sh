#!/usr/bin/env bash
# Run all unit/integration test suites in the monorepo.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

echo "==> iOS unit tests"
SKIP_UI_TESTS=1 ./scripts/run-ios-tests.sh

echo "==> Vapor API (implementation-pack)"
(cd implementation-pack && swift test)

echo "==> Node orchestrator"
(cd platform/orchestrator && npm test)

echo "==> Python onboarding worker"
WORKER_DIR="$ROOT/platform/agents/onboarding-worker"
WORKER_VENV="$WORKER_DIR/.venv"
if [[ ! -d "$WORKER_VENV" ]]; then
  python3 -m venv "$WORKER_VENV"
fi
"$WORKER_VENV/bin/pip" install -q -r "$WORKER_DIR/requirements.txt"
( cd "$WORKER_DIR" && "$WORKER_VENV/bin/python" -c "import app; assert app.app; print('ok')" )

echo ""
echo "All test suites passed."

#!/usr/bin/env python3
"""Copy implementation-pack sources into output/ (for sharing or PDF tooling)."""

from __future__ import annotations

import json
import shutil
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SRC = ROOT / "implementation-pack"
OUT = ROOT / "output"

FILES = [
    "wcs_agentic_operations_manual.md",
    "Package.swift",
    "Dockerfile",
    "docker-compose.yml",
    "README.md",
    "Sources/App/entrypoint.swift",
    "Sources/App/configure.swift",
    "Sources/App/routes.swift",
    "Sources/App/WCSModels.swift",
    "Sources/App/Migrations.swift",
]


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    for rel in FILES:
        s = SRC / rel
        d = OUT / rel
        d.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(s, d)
    meta = {
        "caption": "WCS Swift SaaS Starter",
        "description": "Swift Vapor backend starter for agentic SaaS workflows.",
    }
    (OUT / "wcs_swift_saas_starter.meta.json").write_text(
        json.dumps(meta, indent=2), encoding="utf-8"
    )
    print(f"Copied {len(FILES)} files to {OUT}")


if __name__ == "__main__":
    main()

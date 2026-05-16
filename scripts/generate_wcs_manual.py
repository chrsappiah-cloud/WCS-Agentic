#!/usr/bin/env python3
"""
Generate a long-form manual (~50 printable pages) for the WCS-Agentic iOS app
and its companion Vapor starter (implementation-pack).
"""

from __future__ import annotations

import os
from datetime import date
from pathlib import Path


def hr() -> str:
    return "\n\n---\n\n"


def main() -> None:
    desktop = Path(os.path.expanduser("~/Desktop"))
    out = desktop / "WCS-Agentic_Agentic_App_Manual_50_Pages.md"
    today = date.today().isoformat()

    core = [
        (
            "Executive summary",
            (
                "WCS-Agentic is a SwiftUI + SwiftData iOS client aligned to a Swift/Vapor starter API. "
                "It demonstrates a pragmatic agentic operations posture: bounded automation, explicit API contracts, "
                "local persistence for offline-first UX, and clear separation between presentation, persistence, and networking."
            ),
        ),
        (
            "Primary user journeys today",
            (
                "Operators open the Programs tab to refresh API health, enroll a sample participant, and observe the row persisted via SwiftData. "
                "They switch to the API tab to ping the backend again and read operational guidance about `WCSAPIBaseURL`."
            ),
        ),
        (
            "Configuration: `WCSAPIBaseURL` and local development",
            (
                "`VaporBackendClient` reads `WCSAPIBaseURL` from `Info.plist` and defaults to `http://127.0.0.1:8080`. "
                "`NSAppTransportSecurity` permits local networking for LAN/Vapor iteration. Use `.xcconfig` per build configuration as you mature environments."
            ),
        ),
        (
            "Backend contract (starter)",
            (
                "`GET /health` returns a UTF-8 string used as a connectivity signal. "
                "`POST /participants` accepts `{email, fullName}` JSON and returns a row containing a UUID `id` for client persistence."
            ),
        ),
        (
            "SwiftData persistence model",
            (
                "`ParticipantRecord` stores participant fields and timestamps. `WorkflowRepository` upserts by `id` and saves the model context, "
                "keeping mutations out of views and preserving invariants as the model grows."
            ),
        ),
        (
            "View model responsibilities (`ProgramsViewModel`)",
            (
                "`ProgramsViewModel` is `@MainActor` and owns `lastHealth`, `lastError`, and `isBusy`. "
                "`refreshHealth()` maps failures to `unavailable` and captures localized errors for display."
            ),
        ),
        (
            "Networking seam (`URLSessionHTTPClient` + middleware)",
            (
                "Middleware composes cross-cutting concerns: logging today; auth injection, tracing headers, and retry policies tomorrow. "
                "Keep middleware pure in `prepare` and side-effectful telemetry in `didReceive`."
            ),
        ),
        (
            "Deterministic testing with `MockBackendClient`",
            (
                "`WCS_AgenticApp` selects `MockBackendClient` when `--uitesting` is present, enabling UI tests without a live server. "
                "Unit tests configure `healthBody` and `nextParticipantID` to validate decoding and persistence paths."
            ),
        ),
        (
            "UI tests and accessibility identifiers",
            (
                "UI tests navigate tabs and validate that mock health renders as `ok`. Accessibility identifiers (`tab.programs`, `toolbar.refreshHealth`, …) "
                "keep tests stable; treat identifier churn as a breaking change."
            ),
        ),
        (
            "CI/CD enforcement (repository workflows)",
            (
                "GitHub Actions runs iOS tests via `scripts/run-ios-tests.sh` with `SKIP_UI_TESTS=1` for runner reliability, "
                "and validates `implementation-pack` Docker builds on Linux. Extend with signing/TestFlight when you are ready."
            ),
        ),
    ]

    prompt_pages = [
        (
            "Prompt template: local bring-up",
            "Goal: run backend + confirm iOS connectivity.\n"
            "Constraints: do not change production secrets; only local compose.\n"
            "Steps: `docker compose up --build` in `implementation-pack/`, verify `GET /health`, launch app, refresh health.\n"
            "Stop condition: health string visible and stable across navigation.\n"
            "Rollback: stop containers and revert plist URL if mis-set.",
        ),
        (
            "Prompt template: defect reproduction",
            "Goal: isolate client vs server failure.\n"
            "Constraints: reproduce under `--uitesting` first.\n"
            "Steps: capture `lastError`, reproduce with mock, then with live stub session if needed.\n"
            "Stop condition: minimal failing test exists.\n"
            "Rollback: discard local plist experiments; restore default base URL.",
        ),
        (
            "Prompt template: add a new endpoint safely",
            "Goal: extend API surface without breaking existing flows.\n"
            "Constraints: update `APIServing`, both clients, tests, and UI behind a flag.\n"
            "Steps: define JSON contract, add fixtures, implement decode, ship UI action.\n"
            "Stop condition: unit tests cover success + failure + decoding drift.\n"
            "Rollback: disable flag; keep server backward compatible.",
        ),
        (
            "Prompt template: SwiftData migration",
            "Goal: evolve schema with minimal user disruption.\n"
            "Constraints: backward compatible reads for one release.\n"
            "Steps: add optional fields, default values, migration test, backfill on sync.\n"
            "Stop condition: old stores open; new field populated after online refresh.\n"
            "Rollback: feature gate writes to new field until stable.",
        ),
        (
            "Prompt template: security hardening pass",
            "Goal: reduce exposure before wider distribution.\n"
            "Constraints: no PII in logs; TLS for non-local; Keychain for tokens.\n"
            "Steps: redact middleware logs, add ATS exceptions review, document data classes.\n"
            "Stop condition: checklist completed and reviewed by second engineer.\n"
            "Rollback: revert logging changes if crash diagnostics regresses.",
        ),
    ]

    ops_pages = [
        "Operational discipline",
        "Measurement and KPIs",
        "Documentation hygiene",
        "Stakeholder communication",
        "Risk registers",
        "Dependency updates",
        "Supply chain security",
        "Secrets rotation",
        "Backup and restore drills",
        "Load testing mindset",
        "Chaos testing introduction",
        "Configuration management",
        "Staging parity",
        "Blue/green releases",
        "Canary releases",
        "Feature toggles hygiene",
        "Runbook templates",
        "Blameless postmortems",
        "Definition of done",
        "Sprint planning prompts",
        "Backlog refinement prompts",
        "Customer research prompts",
        "Usability testing scripts",
        "Design critique prompts",
        "Architecture decision records",
        "Threat modeling cadence",
        "Vendor management prompts",
        "LLM budget guardrails",
        "Prompt evaluation harnesses",
        "Grounding and citations policy",
        "Red teaming cadence",
        "Safety review checklist",
        "Model versioning policy",
        "Dataset governance",
        "Bias and fairness reviews",
        "Localization workflow",
        "Support escalation matrix",
        "SLA definitions",
        "On-call health checks",
        "Runbook: API rollback",
        "Runbook: client hotfix",
        "Runbook: communications templates",
        "Roadmap: authentication",
        "Roadmap: background sync",
        "Roadmap: admin dashboards",
        "Roadmap: agent orchestration",
        "Roadmap: document intelligence",
        "Roadmap: certificate preparation agent",
        "Roadmap: incident automation",
    ]

    # Build exactly 50 pages: combine authored slices + prompt templates + ops pages.
    pages: list[str] = []

    def add_page(n: int, title: str, body: str) -> None:
        suffix = (
            "\n\n#### Workshop exercises (print-friendly)\n\n"
            f"**Exercise A — traceability (page {n})**: Rewrite the guidance above as a checklist with owners. "
            "For each item, specify evidence you would accept in a review (log line, test name, screenshot, PR link).\n\n"
            "**Exercise B — failure modes**: Identify three realistic failures (network, decoding, persistence). "
            "For each, write the operator-facing message and the engineer-facing next step.\n\n"
            "**Exercise C — automation boundary**: Decide whether this page’s topic may be automated end-to-end, partially automated, "
            "or must remain human-only. Justify with risk, reversibility, and data sensitivity.\n\n"
            "**Exercise D — prompt upgrade**: Improve a generic assistant prompt into a production-grade prompt by adding constraints, "
            "tool allowlists, success criteria, and rollback language.\n\n"
            "**Exercise E — measurement**: Pick one metric that would detect regressions related to this page. Define numerator, denominator, "
            "segmentation dimensions (app version, OS version, environment), and alert thresholds.\n\n"
            "#### Notes for institutional deployment\n\n"
            "Institutions differ in lawful basis, retention, and acceptable hosting regions. Treat this manual as a template: replace "
            "placeholders with your policy references, RACI assignments, and escalation contacts. Keep engineering artifacts (tests, CI logs, "
            "architectural decisions) adjacent to policy statements so audits can connect controls to implementation.\n\n"
            "#### Connection to the WCS-Agentic codebase\n\n"
            "Where relevant, map guidance to concrete seams: `APIServing` for contracts, `VaporBackendClient` for transport, "
            "`URLSessionHTTPClient` for middleware, `WorkflowRepository` for persistence, SwiftUI views for experience, and "
            "`implementation-pack/` for the Vapor starter and Docker bring-up.\n"
        )
        pages.append(f"# Page {n}: {title}{hr()}{body.strip()}{suffix}\n")

    n = 1
    add_page(
        n,
        "Title, scope, and how to read this manual",
        f"# World Class Scholars — WCS-Agentic Manual\n\n"
        f"_Uses, features, functions, and prompt-driven workflow automation guidelines._\n\n"
        f"_Generated: {today}_\n\n"
        "This manual is intentionally paginated for printing and audit trails. Each page targets roughly one printed page "
        "when rendered at typical body sizes (about 300–450 words per page depending on font and margins).\n\n"
        "**Who should read this**: iOS engineers, backend engineers, program operators, and anyone designing supervised "
        "automation around participant workflows.\n\n"
        "**What this app is today**: a SwiftUI client with SwiftData persistence, a mock/live API boundary, middleware-ready "
        "HTTP transport, and tests that encode expected behavior.\n\n"
        "**What this app is becoming**: a front door to agentic workflows—bounded tools, explicit approvals, measurable outcomes—"
        "as described in `implementation-pack/wcs_agentic_operations_manual.md`.\n",
    )
    n += 1

    for title, para in core:
        add_page(
            n,
            title,
            f"{para}\n\n"
            "#### Repeatable execution checklist\n\n"
            "1. State the boundary: UI, API client, persistence, tests, or CI.\n"
            "2. State the risk: what could go wrong for participants or operators.\n"
            "3. Ship the smallest vertical slice.\n"
            "4. Add a regression test.\n"
            "5. Record a one-paragraph operational note for the next on-call.\n",
        )
        n += 1

    for title, block in prompt_pages:
        add_page(
            n,
            title,
            f"```{block}```\n\n"
            "#### Automation guidance\n\n"
            "When you paste prompts into an assistant, include your repository constraints: SwiftUI/SwiftData on iOS, Vapor starter "
            "in `implementation-pack/`, and the requirement that new behavior must arrive with tests.\n\n"
            "#### Governance reminder\n\n"
            "Prompts accelerate execution; they do not replace policy. Identity, certificates, mass communications, and "
            "irreversible actions should remain human-gated until measurement thresholds are met.\n",
        )
        n += 1

    for topic in ops_pages:
        if n > 50:
            break
        add_page(
            n,
            f"Operating discipline — {topic}",
            f"This page is a reusable workshop module themed around **{topic}** for the WCS-Agentic program.\n\n"
            "#### Planning prompt (10 minutes)\n\n"
            f"“List the top five risks for {topic.lower()} in our current WCS-Agentic milestone. "
            "For each risk, specify detection signals, mitigations, owners, and deadlines.”\n\n"
            "#### Execution prompt (30–90 minutes)\n\n"
            f"“Deliver the smallest measurable improvement to {topic.lower()} without expanding feature scope. "
            "Prefer tests, observability, and documentation over new UI.”\n\n"
            "#### Review prompt (15 minutes)\n\n"
            "“What evidence proves we improved safety or reliability? What did we intentionally defer?”\n",
        )
        n += 1

    # If still short (shouldn't be), pad with appendices.
    while n <= 50:
        add_page(
            n,
            f"Appendix continuation — engineering notebook ({n})",
            "This appendix page is intentionally open-ended: use it for institutional specifics—URLs, contacts, escalation "
            "paths, and compliance references that should not live in public repositories.\n\n"
            "#### Prompt — capture institutional context\n\n"
            "“Summarize the program’s data classification policy, retention policy, and approved hosting regions. Map each policy "
            "statement to a concrete control in the iOS client or Vapor service.”\n\n"
            "#### Prompt — define ‘done’ for automation\n\n"
            "“For each automated workflow, define inputs, outputs, allowed tools, forbidden actions, human approval points, and rollback.”\n",
        )
        n += 1

    out.write_text("".join(pages).rstrip() + "\n", encoding="utf-8")
    words = len(out.read_text(encoding="utf-8").split())
    print(f"Wrote {out} ({words} words)")


if __name__ == "__main__":
    main()

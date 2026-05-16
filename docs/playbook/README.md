# World Class Scholars — Agentic AI Playbook

Three modules: **Exploring → Implementing → Scaling**, with checklists, decision gates, RACI, and measurable success metrics.

| Module | Document | Outcome |
|--------|----------|---------|
| 1 — Exploring | [01-exploring.md](01-exploring.md) | Prioritized pilots, risk profile, MVP spec |
| 2 — Implementing | [02-implementing.md](02-implementing.md) | Architecture choice, scaffold, pilot metrics |
| 3 — Scaling | [03-scaling.md](03-scaling.md) | Governance tiers, phased rollout, operations |
| Patterns | [architecture-patterns.md](architecture-patterns.md) | Agent Workflow, Autonomous FE, Deterministic peers |
| Governance | [governance.md](governance.md) | Policy-as-code, runtime controls, audit/NIST mapping |
| RACI & metrics | [raci-and-metrics.md](raci-and-metrics.md) | Roles, gates, KPIs per workflow |

**Runnable scaffold:** [`platform/`](../../platform/) — orchestrator (Node), agent workers (Python), OPA policies, governance UI, Docker Compose, Terraform (AWS).

**Mobile + API slice:** [`WCS-Agentic/`](../../WCS-Agentic/) iOS app + [`implementation-pack/`](../../implementation-pack/) Vapor API.

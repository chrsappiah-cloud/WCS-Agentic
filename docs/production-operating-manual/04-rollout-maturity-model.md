# Rollout maturity model

Phased deployment aligned with case-study maturity models: prove value under supervision before expanding autonomy.

## Stages

| Stage | Scope | Autonomy | Gate (G#) |
|-------|-------|----------|-----------|
| **0 — Design** | Specs, policies, mock adversarial tests | None | G0 |
| **1 — Pilot** | Onboarding only; human approval queue | Low-risk steps automated | G0 → G1 |
| **2 — Supervised production** | + certificate prep, support triage | Sensitive actions gated | G1 → G2 |
| **3 — Multi-agent coordination** | Shared sessions, conflict resolver live | Partial autonomy on low-risk | G2 |
| **4 — Optimization** | Dashboards, A/B policies, drift monitoring | Tunable per workflow | G2 sustained |
| **5 — Scale-out** | SaaS packaging for partner orgs | Tiered per tenant policy | G3 |

## Stage 1 — Pilot (onboarding)

**Duration:** 4–8 weeks  
**Success criteria:**

- Median time-to-ready −40% vs baseline
- ID precision ≥ 0.95, recall ≥ 0.90
- Zero critical policy violations
- 100% audit completeness on tool calls

**Human capacity:** Plan reviewer SLA (e.g., &lt; 4h business hours for ID queue).

## Stage 2 — Supervised production

Add:

- Certificate **preparation** (deterministic graph)
- Support triage agent (suggest-only until reviewer accepts)

**Hard rule:** certificate **issuance** remains dual-control; no LLM in commit path.

## Stage 3 — Multi-agent coordination

- Orchestrator session mutex per participant
- Policy-based conflict resolution ([02-universal-control-stack.md](02-universal-control-stack.md))
- Event bus for async handoffs (certificate prep triggered on onboarding complete)

## Stage 4 — Optimization

- Per-workflow token budgets and cost dashboards
- Red-team quarterly on policy bypass and exfiltration paths
- Blue/green for worker model versions
- A/B policy bundles with automatic rollback on error-rate spike

## Stage 5 — Scale-out (SaaS)

- Tenant isolation (DB schema or row-level + KMS per tenant)
- Configurable policy packs per jurisdiction
- Self-serve onboarding of new orgs with sandbox tier

## Gate summary

| Gate | Approvers | Evidence pack |
|------|-----------|---------------|
| G0 → Pilot | Ops + Engineering | MVP spec, PII DPIA, mock tests |
| G1 → Supervised | + Legal/Security | 30d pilot metrics, runbook |
| G2 → Partial autonomy | Governance board | Error budget, queue SLA, cost/workflow |
| G3 → Scale / SaaS | Board + Security | DR test, tenant isolation review, SOC2 path |

Full RACI: [raci-and-metrics.md](../playbook/raci-and-metrics.md).

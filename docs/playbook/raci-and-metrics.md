# RACI & success metrics

## RACI (program-level)

| Activity | Program Director | Ops Lead | Engineering | Legal/Security | Faculty/Leadership |
|----------|------------------|----------|-------------|----------------|--------------------|
| Process prioritization | A | R | C | C | I |
| Pattern selection | A | C | R | C | I |
| Policy definition | A | C | C | R | I |
| Pilot execution | I | R | R | C | I |
| Production gate | A | R | C | C | I |
| Incident response | I | R | R | C | I |

A = Accountable · R = Responsible · C = Consulted · I = Informed

## Decision gates

| Gate | Criteria (all must pass) |
|------|--------------------------|
| G0 → Pilot | MVP spec signed; PII controls documented; mock adversarial tests green |
| G1 → Supervised production | Precision/recall ≥ targets; audit trail complete; on-call runbook |
| G2 → Partial autonomy | Error budget 30d green; human queue SLA met; cost/workflow within budget |
| G3 → Scale | Governance board sign-off; drift monitoring live; rollback tested |

## KPIs — participant onboarding (example)

| Metric | Target (pilot) | Target (scale) |
|--------|----------------|----------------|
| Time-to-ready (median) | −40% vs baseline | −55% |
| ID extraction precision | ≥ 0.95 | ≥ 0.97 |
| ID extraction recall | ≥ 0.90 | ≥ 0.93 |
| % completed without human approval (low-risk only) | ≤ 30% | ≤ 50% |
| Escalation rate to Tier 1 | tracked | < 15% |
| Cost per onboarding (tokens + infra) | <$X | −20% YoY |
| Policy violation rate (blocked actions) | 0 critical | 0 critical |

## KPIs — certificate operations

| Metric | Target |
|--------|--------|
| Preparation automation rate | ≥ 80% payloads auto-built |
| Silent issuance incidents | **0** (hard gate) |
| Dual-control compliance | 100% issuances with approver ID in audit log |
| Audit log completeness | 100% tool calls + model version captured |

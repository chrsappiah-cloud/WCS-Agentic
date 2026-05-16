# Module 3 — Scaling Agentic AI

## Step 1 — Governance & risk posture

**Checklist**

- [ ] Define tiers: **Sandbox** → **Supervised** → **Autonomous (bounded)** → **Scale**
- [ ] Charter governance board (product, legal, security, ops, ethics)
- [ ] Map controls to NIST CSF / ISO 27001 themes (identify, protect, detect, respond, recover)
- [ ] Retention & audit policy signed (immutable logs, PII minimization)

## Step 2 — Phased deployment

| Phase | Scope | Gate |
|-------|-------|------|
| Pilot | Single workflow, <500 subjects | G0 |
| Supervised production | Multi-workflow, all high-risk gated | G1 |
| Partial autonomy | Low-risk nodes automated | G2 |
| Scale | Full program, cost governance | G3 |

**Checklist**

- [ ] SLOs: uptime, p95 latency, correctness sampling, human queue depth
- [ ] Per-workflow and per-agent token budgets enforced in orchestrator
- [ ] Rollback plan for model/policy changes (blue/green + feature flags)

## Step 3 — Operationalization

**Checklist**

- [ ] Queue-based scaling (orchestrator + workers autoscale)
- [ ] Central policy distribution (OPA bundle via CI)
- [ ] OpenTelemetry → dashboards (traces, metrics, logs correlated by session ID)
- [ ] Drift detection on extraction models and policy denials
- [ ] A/B policy changes with guardrails

## Step 4 — Organization & training

**Checklist**

- [ ] Operator training: approval queue, kill-switch, incident comms
- [ ] SOP updates for Tier 0/1/2 escalation
- [ ] Incident playbooks: containment, rollback, participant notification
- [ ] Feedback loop from audit logs into prompt/policy updates

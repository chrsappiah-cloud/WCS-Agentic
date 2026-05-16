# Module 2 — Implementing Agentic AI

## Step 1 — Architecture & pattern selection

**Checklist**

- [ ] Assign pattern per process (see [architecture-patterns.md](architecture-patterns.md))
- [ ] Map components: Orchestrator, Workers, Connectors, Policy Engine, Observability, UI
- [ ] Choose event bus (Kafka / Pub/Sub / in-process for pilot)
- [ ] Define session model: budgets, handoffs, retries, dead-letter queue

**WCS reference stack (this repo)**

| Component | Implementation |
|-----------|----------------|
| Orchestrator | `platform/orchestrator` (Node/Express) |
| Domain API | `implementation-pack` (Vapor/Fluent) |
| Mobile ops UI | `WCS-Agentic` (SwiftUI) |
| Agent worker | `platform/agents/onboarding-worker` (Python) |
| Policy | `platform/governance/policies` (OPA/Rego) |
| Approvals UI | `platform/governance-ui` (React) |

## Step 2 — Scaffolding & orchestration

**Checklist**

- [ ] Orchestrator exposes workflow start/status/approve APIs (OpenAPI)
- [ ] Workers declare capabilities + max tokens + allowed tools
- [ ] Sync vs async handoffs documented per node
- [ ] Deterministic fallback when LLM/tool fails (queue human, no silent skip)

## Step 3 — Safety & governance in code

**Checklist**

- [ ] Policies as code: allowed actions, data scopes, token budgets, max loops
- [ ] Pre-action authorization hook in orchestrator
- [ ] Post-action audit log (tool, model ID/version, classification)
- [ ] Approval UI for Tier 1 queue
- [ ] Kill-switch tested in staging

## Step 4 — Pilot design & metrics

**Checklist**

- [ ] Define precision/recall targets for extraction tasks
- [ ] Measure % automated completions *without* bypassing gates
- [ ] Cost per workflow (tokens + compute)
- [ ] Red-team: policy bypass, exfiltration, prompt injection on uploads
- [ ] Weekly review with Program Director + Ops Lead

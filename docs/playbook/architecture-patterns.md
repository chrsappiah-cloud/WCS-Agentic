# Architecture patterns & selection

## Pattern A — Sequenced Agent Workflow

**Use when:** Multi-step processes, shared state, validation between steps (onboarding, co-design).

```
[Orchestrator] → Agent A → validate → Agent B → validate → Human gate → Agent C → audit
```

- Orchestrator owns session, budgets, retries
- Each agent: single purpose, explicit I/O schema
- **WCS examples:** onboarding, campaign draft with editorial queue

## Pattern B — Autonomous Front-End

**Use when:** Low-risk, exploratory queries; strict caps on tools and tokens.

- Hard token budget per session
- No access to write tools without policy allow
- Transactional handoff to human or workflow on ambiguity
- **WCS example:** campus assistant FAQ (pilot only)

## Pattern C — Deterministic Peer Nodes

**Use when:** Regulated, auditable, BPMN-like flows (certificate issuance).

- Immutable audit trail per transition
- No LLM in commit path without human approval node
- **WCS example:** certificate preparation → approval → issuance record

## Selection matrix

| Criterion | Agent Workflow | Autonomous FE | Deterministic |
|-----------|----------------|---------------|---------------|
| Regulatory exposure | Medium–High | Low | High |
| Steps > 3 | Yes | No | Yes |
| Needs LLM creativity | Yes | Yes | Rarely |
| Requires immutable audit | Yes | Partial | **Required** |
| Human approval | Per node | On escalation | **Mandatory** at commit |

## Core platform components (reference design)

| Component | Responsibility |
|-----------|----------------|
| Orchestrator | Sessions, scheduling, budgets, handoffs, audit |
| Agent workers | Execute one capability; call tools via connectors |
| Tool connectors | Drive, email, CRM, LMS — scoped credentials |
| Policy engine | OPA/Rego pre/post hooks |
| Event bus | Async fan-out (optional at pilot) |
| Observability | OpenTelemetry, session replay |
| AuthN/Z | OIDC + RBAC |
| Data vault | Encrypted object store + KMS |
| Governance UI | Approvals, audit viewer |

See runnable layout in [`platform/README.md`](../../platform/README.md).

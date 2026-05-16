# Universal control stack (every WCS workflow)

Every production workflow uses the same seven stages. This mirrors coordination logic from multi-agent systems: bounded action spaces, explicit state, measurable outcomes.

```
┌─────────┐   ┌────────────┐   ┌─────────┐   ┌──────────┐   ┌────────┐   ┌───────────┐   ┌──────────┐
│ Intake  │ → │ Validation │ → │ Scoring │ → │ Decision │ → │ Action │ → │ Audit log │ → │ Fallback │
└─────────┘   └────────────┘   └─────────┘   └──────────┘   └────────┘   └───────────┘   └──────────┘
```

## Stage definitions

| Stage | Responsibility | WCS implementation |
|-------|----------------|-------------------|
| **Intake** | Accept request, authenticate caller, attach correlation ID | API gateway / orchestrator `POST /workflows/{type}/start` |
| **Validation** | Schema, consent, RBAC, data completeness | JSON schema + OPA `input.consent` + profile flags |
| **Scoring** | Risk, confidence, cost estimate | Worker returns `riskTier`, `confidence`; orchestrator enforces token budget |
| **Decision** | Next node, approval required, or block | Policy engine + orchestrator state machine |
| **Action** | Tool calls (email, CRM, LMS, storage) | Connectors with scoped credentials; idempotent where possible |
| **Audit trail** | Immutable append-only event per step | `store.audit()` → export to audit store / SIEM |
| **Fallback** | Retry, human queue, kill-switch, compensating action | Approval UI, `WCS_KILL_SWITCH`, session terminate |

## Pre-action checklist (orchestrator)

Before any agent or tool invocation:

1. Session not killed; budget remaining
2. OPA `allow` for `(role, action, resource)`
3. Workflow state permits transition
4. PII scope matches connector credential
5. Loop count &lt; `maxLoops` (default 12)

## Post-action checklist

1. Append audit event (actor, model version, tokens, tool calls)
2. Update session graph node status
3. If confidence &lt; threshold or risk ≥ medium → queue human approval
4. Emit metric (latency, success, escalation)

## Conflict resolution (consensus layer)

When two workflows target the same participant:

1. Load participant lock / session mutex (orchestrator)
2. Evaluate policies for priority: **safety &gt; compliance &gt; onboarding &gt; engagement**
3. If tie: queue decision to ops reviewer with both session IDs
4. Never run certificate **issuance** while onboarding ID review is `pending`

## Fallback matrix

| Condition | Fallback |
|-----------|----------|
| Worker timeout (3x retry) | Human queue + notify ops |
| Policy deny | Block + audit `policy_denied` |
| Budget exceeded | Pause session + approval to extend budget |
| Low confidence extraction | Human ID review (mandatory) |
| Runaway loop | Kill-switch + incident ticket template |
| Connector failure | Dead-letter queue + compensating email to participant |

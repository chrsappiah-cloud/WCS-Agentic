# Workflow 3 — Certificate operations agent

**Pattern:** Deterministic Peer Nodes (BPMN-like; LLM not in commit path)  
**Autonomy tier:** Supervised — **never issue without policy confirmation and approver**

## Purpose

Check completion rules, validate identity consistency, build issuance payload, route to dual-control approval, record immutable issuance event.

## Actors

| Role | Responsibility |
|------|----------------|
| Certificate ops worker | Rule evaluation, payload assembly |
| Orchestrator | Deterministic state machine only |
| Approver A / B | Dual control (can be same role pool, different users) |
| Vapor API | Certificate record + hash |

## Control stack

| Stage | Actions |
|-------|---------|
| Intake | Trigger: course completion event OR manual request |
| Validation | Participant `status=active`; ID verified; completion rules met |
| Scoring | N/A for LLM; rule engine returns pass/fail per criterion |
| Decision | All rules green → queue issuance approval; any fail → block with reason codes |
| Action | Build payload (participantId, courseId, templateId, hashes); **no** public cert until approve |
| Audit | Immutable log: rule versions, approver IDs, payload hash, timestamp |
| Fallback | Manual certificate desk queue |

## Deterministic graph

```
[completion_event] → [rules_check] → [identity_reverify] → [payload_build] → [approval_A] → [approval_B] → [issuance_record] → [notify]
         │ fail任何节点 → [blocked] + audit reason
```

## Human control points

1. **Mandatory:** Dual approval before `issuance_record`
2. **Mandatory:** Identity re-verify if onboarding &gt; 90 days ago
3. **Forbidden:** Auto-issuance via LLM tool call (policy enforced)

## Joint-action coordination

- Mutex: cannot enter `payload_build` while onboarding session has `id_review=pending`
- On onboarding complete → eligible for `rules_check` (event-driven)

## KPIs

| Metric | Target |
|--------|--------|
| Preparation automation rate | ≥ 80% payloads auto-built |
| Silent issuance incidents | **0** (release blocker) |
| Dual-control compliance | 100% with approver ID in audit |
| Fraud/anomaly flags | 100% investigated within SLA |

## Policy hooks (OPA)

```rego
# Illustrative — see platform/governance/policies/wcs.rego
deny[msg] {
  input.action == "issue_certificate"
  not input.approval.dual_control_complete
  msg := "dual control required"
}
```

## Implementation status

| Item | Status |
|------|--------|
| Spec (this doc) | ✅ |
| Orchestrator workflow | Phase 2 — `workflows/certificate.js` |
| Worker | Phase 2 — rule engine + template render |
| Vapor `certificates` endpoint | Extend implementation-pack |

## Test plan

- Completion without ID → blocked
- Single approval → deny issuance
- Tampered payload hash → detect on verify
- Concurrent onboarding → mutex blocks issuance

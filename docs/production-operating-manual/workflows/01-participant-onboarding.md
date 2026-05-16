# Workflow 1 — Participant onboarding agent

**Pattern:** Sequenced Agent Workflow (joint-action with certificate prep handoff optional)  
**Autonomy tier:** Supervised — human at ID review and participant record create  
**Reference implementation:** `platform/orchestrator/src/workflows/onboarding.js`

## Purpose

Collect profile fields, verify email, request passport/ID, classify risk, route edge cases to human reviewer, create participant record only after approval.

## Actors

| Role | RACI |
|------|------|
| Participant | Provides data and documents |
| Onboarding worker agent | Extracts, classifies risk |
| Orchestrator | Session, budget, sequencing |
| Reviewer | Approves/denies ID and profile |
| Vapor API | System of record for participants |

## Control stack

| Stage | Actions |
|-------|---------|
| Intake | `POST /workflows/onboarding/start` with email, consent flags |
| Validation | Consent true; email format; document MIME allowlist |
| Scoring | Worker returns `riskTier`, `confidence`, `tokensUsed` |
| Decision | If risk=high OR confidence&lt;0.85 → approval queue; else optional auto-path (policy-defined) |
| Action | Email confirm (simulated/prod), ID extract, CRM draft, `POST /participants` after approve |
| Audit | `session_created`, `id_extract`, `approval_queued`, `workflow_completed` |
| Fallback | Worker retry 3x; then human queue; kill-switch pauses all sessions |

## Sequence

```
Participant → Orchestrator → [email_confirm] → Worker (ID extract) → Approval UI → Vapor (create) → Complete
```

## Human control points

1. **Mandatory:** ID document review when `riskTier != low` OR `confidence < 0.85`
2. **Mandatory:** First participant create in production (policy `require_human_create`)
3. **Optional pilot:** `WCS_AUTO_APPROVE=1` dev only

## Data & connectors

| System | Access |
|--------|--------|
| Object storage | Upload passport/ID (encrypted) |
| Email | Verification link |
| CRM | Draft contact (no promote without approval) |
| Vapor | Participant create |

## KPIs

| Metric | Pilot target |
|--------|--------------|
| Median time-to-ready | −40% vs baseline |
| ID precision / recall | ≥ 0.95 / ≥ 0.90 |
| % auto-completed (low-risk only) | ≤ 30% |
| Escalation to Tier 1 | track; target &lt; 15% at scale |
| Cost per onboarding | establish baseline |

## Policy hooks (OPA)

- `action == "extract_id"` → role `onboarding_worker`, scope `documents:read`
- `action == "create_participant"` → requires `approval.granted == true`
- Token budget: default 2000 tokens/session

## Test plan

- Happy path with mock passport → approval → participant created
- Low-confidence doc → must queue approval
- Policy deny on create without approval → 403 + audit
- Kill-switch mid-session → session paused, no create

## Phase 2 enhancements

- Real OCR model + liveness check vendor
- Mentor-match agent node after create
- CRM promote on approval

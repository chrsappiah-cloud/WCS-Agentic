# Workflow 2 — Learning-path concierge agent

**Pattern:** Autonomous Front-End (read-heavy) + scheduled nudge events  
**Autonomy tier:** Partial — no unsupervised PII writes or enrollment commits

## Purpose

Recommend modules, nudge unfinished tasks, personalize content by role, interests, and completion status.

## Actors

| Role | Responsibility |
|------|----------------|
| Participant | Consumes recommendations via portal/app |
| Concierge agent | Ranks modules, drafts nudges |
| LMS connector | Read progress, completions |
| Orchestrator | Optional: scheduled nudge sessions with token caps |

## Control stack

| Stage | Actions |
|-------|---------|
| Intake | Authenticated participant session; `GET /recommendations` or chat turn |
| Validation | Participant ID matches token; no cross-tenant reads |
| Scoring | Relevance score + explanation string (for audit) |
| Decision | Cap recommendations at N=5; block if LMS unavailable |
| Action | Return ranked list; queue email/push only if opt-in |
| Audit | Log model version, sources (module IDs), no raw PII in prompts stored |
| Fallback | Static curriculum path if agent unavailable |

## Human control points

- **None** for read-only recommendations
- **Required** if recommending program **switch** or waiver (route to advisor queue)
- Editorial review if generated content shown publicly

## Constraints (independent learner pattern)

- Separate worker from onboarding/certificate agents
- Supervisor reviews **exceptions** only (advisor queue)
- Hard token budget: 800 tokens/user/day (configurable)

## KPIs

| Metric | Target |
|--------|--------|
| Click-through on recommendations | +15% vs baseline |
| Module completion rate (cohort) | +10% at 90d |
| Nudge opt-out rate | &lt; 5% |
| Hallucinated module references | **0** (validator checks LMS IDs) |

## Implementation notes

| Component | Status |
|-----------|--------|
| iOS Programs tab | UI surface (extend to call recommendations API) |
| Orchestrator route | `POST /workflows/concierge/start` — **spec only** |
| Worker | `platform/agents/concierge-worker/` — Phase 2 |
| LMS connector | Read-only API key scoped to progress endpoints |

## Sequence (nudge batch)

```
Scheduler → Orchestrator → Concierge worker → LMS read → Policy allow → Send nudge (if opt-in) → Audit
```

## Policy hooks

- Deny `write:enrollment`, `write:grades`
- Allow `read:lms_progress` for self only
- Block recommendations referencing unpublished modules

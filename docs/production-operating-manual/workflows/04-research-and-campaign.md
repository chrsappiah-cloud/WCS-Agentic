# Workflow 4 — Research & campaign agent

**Pattern:** Sequenced Agent Workflow with **editorial approval** gate  
**Autonomy tier:** Supervised — publish and external send blocked until human approve

## Purpose

Draft program insights, summarize participant feedback (aggregated/de-identified where possible), produce campaign assets with **source citations**, route to editorial queue before publish or send.

## Actors

| Role | Responsibility |
|------|----------------|
| Research agent | Summarize, draft, cite sources |
| Analytics connector | Read aggregated feedback, survey exports |
| Editor | Approve copy, claims, and audience |
| Orchestrator | Workflow session + token budget |

## Control stack

| Stage | Actions |
|-------|---------|
| Intake | Campaign brief (objective, audience, tone, deadline) |
| Validation | No raw PII in prompt context; sources must be allowlisted |
| Scoring | Citation coverage score; claim-risk flagger |
| Decision | High claim-risk → mandatory editorial; else draft to queue |
| Action | Write draft to CMS `status=draft` only; no email blast |
| Audit | Source doc IDs, model version, editor decision |
| Fallback | Human-only draft template |

## Human control points

1. **Mandatory:** External publish, email send, social post
2. **Mandatory:** Any statistic about participants (verify against warehouse)
3. **Recommended:** All public-facing copy in pilot

## Citation requirements

Every factual bullet must include:

- `sourceId` (document, survey wave, or dashboard snapshot ID)
- `retrievedAt` timestamp
- `confidence` (high/medium/low)

Editor may reject insufficient citations.

## KPIs

| Metric | Target |
|--------|--------|
| Editor acceptance without major rewrite | ≥ 60% (pilot) |
| Citation coverage on factual claims | 100% |
| PII leakage incidents | **0** |
| Time brief-to-approved-draft | −30% vs manual |

## Sequence

```
Brief → Research worker (retrieve sources) → Draft + citations → Editorial approval → CMS publish / campaign send
```

## Policy hooks

- Deny `send:email_external` without `editorial.approved`
- Deny prompts containing `participant.email`, `passport`, free-text PII fields
- Max tokens 4000/session; max 3 retrieval loops

## Implementation status

| Item | Status |
|------|--------|
| Spec | ✅ |
| Worker `research-worker` | Phase 2 |
| Connectors | Google Drive read-only, warehouse read |
| Governance UI | Extend approval type `editorial_review` |

## Red-team scenarios

- Prompt injection via uploaded feedback doc
- Attempt to exfiltrate PII via “summarize all participants”
- Uncited statistical claim → must fail validation gate

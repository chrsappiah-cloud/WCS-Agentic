# Production architecture (layered agent platform)

One giant autonomous agent is an anti-pattern. WCS production uses **layers** with clear contracts.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│ Frontend: participant portal · admin console · reviewer dashboard           │
├─────────────────────────────────────────────────────────────────────────────┤
│ API layer: OIDC auth · workflow orchestration · policy enforcement · intake │
├─────────────────────────────────────────────────────────────────────────────┤
│ Agent layer: onboarding · certificate · support · content · analytics     │
├─────────────────────────────────────────────────────────────────────────────┤
│ Data: PostgreSQL · object storage (documents) · event log · audit store     │
├─────────────────────────────────────────────────────────────────────────────┤
│ Governance: approvals · RBAC · retention · incident playbooks               │
├─────────────────────────────────────────────────────────────────────────────┤
│ DevSecOps: CI/CD · SAST/DAST · deps · secrets · release gates               │
└─────────────────────────────────────────────────────────────────────────────┘
```

## Component map (this repository)

| Layer | Technology (current / target) | Path |
|-------|------------------------------|------|
| Mobile client | SwiftUI + SwiftData | `WCS-Agentic/` |
| Domain API | Vapor + Fluent | `implementation-pack/` |
| Orchestrator | Node/TypeScript + Express | `platform/orchestrator/` |
| Agent workers | Python (Flask) | `platform/agents/` |
| Policy | OPA/Rego | `platform/governance/policies/` |
| Governance UI | Static HTML → React/Next.js | `platform/governance-ui/` |
| Infra local | Docker Compose | `platform/docker-compose.yml` |
| Infra cloud | Terraform (AWS) | `platform/terraform/aws/` |

## Target SaaS stack (production-grade)

| Concern | Recommendation |
|---------|----------------|
| Web portal | Next.js or React (SSR for SEO where needed) |
| Orchestrator | Node/TypeScript (existing) |
| Workers | Python for OCR/classification/reasoning |
| State & queues | PostgreSQL + Redis |
| Documents | S3-compatible + KMS |
| Auth | OIDC + RBAC (roles: participant, reviewer, admin, agent-service) |
| Events | Kafka or managed Pub/Sub (Phase 3+) |
| Observability | OpenTelemetry → backend |
| Contracts | OpenAPI between orchestrator ↔ workers ↔ Vapor |

## Agent responsibilities

| Agent | Capabilities | Write scope |
|-------|--------------|-------------|
| Onboarding | Email verify, ID extract, risk classify, CRM profile draft | Participant draft only after approval |
| Certificate ops | Rule check, identity re-verify, issuance **payload** build | **No** issuance commit |
| Learning-path concierge | Recommend modules, nudges, read LMS progress | Read-mostly; no PII export |
| Support triage | Classify ticket, suggest reply, route | CRM notes (supervised) |
| Content tagging | Tag assets, metadata | CMS write (low risk) |
| Analytics | Aggregates, cohort reports | Read-only warehouse |
| Research & campaign | Summarize feedback, draft copy + citations | Drafts only until editorial approve |

## Service boundaries

- **Orchestrator** owns session lifecycle, budgets, handoffs, audit—not business persistence.
- **Vapor API** owns canonical participant/course/certificate records.
- **Workers** are stateless; all context passed in/out as versioned JSON schemas.
- **Policy engine** is sidecar; decisions versioned in CI with the deploy bundle.

## Security operations alignment

| Control | Maps to |
|---------|---------|
| Pre/post invocation hooks | NIST AC-3, AU-2 |
| Kill-switch | IR containment |
| Token budgets | Resource availability / cost governance |
| Session replay | AU-9, forensic readiness |
| Approval gates | SoD for issuance and PII commits |
| CI policy tests | SA-11 shift-left |

See [governance.md](../playbook/governance.md) for Rego examples and runtime controls.

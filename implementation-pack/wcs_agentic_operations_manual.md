# World Class Scholars — Agentic Production Operating Manual

Version 1.0 · Swift-first server architecture (Vapor) aligned with supervised agentic operations

## Document control

This manual turns recurring enterprise patterns—multi-agent coordination, equilibrium-style conflict resolution, phased maturity, vulnerability handling, and continuous governance—into **operating procedures** World Class Scholars can implement. It assumes **selective autonomy**: agents accelerate repeatable work; **identity, certificates, policy, and mass communications remain human-gated** until trust and measurement thresholds are met.

## Executive operating model

WCS runs a **layered agent platform**, not a single autonomous assistant.

- **Experience layer:** participant portal, admin console, reviewer dashboard.
- **API layer:** authentication, workflow orchestration, policy enforcement, file intake (Swift/Vapor or equivalent).
- **Agent layer:** onboarding, certificate preparation, support triage, content, analytics—each with bounded tools and budgets.
- **Data layer:** PostgreSQL, object storage for documents, immutable event log, audit store.
- **Governance layer:** approvals, RBAC, retention, incident playbooks.
- **DevSecOps layer:** CI/CD, dependency and secret scanning, SAST/DAST, release gates.

**Core principle:** coordination must be **constrained**, not only automated. Every workflow uses explicit state, bounded actions, supervised transitions, and an audit trail.

## Case-study themes (source patterns → WCS interpretation)

Enterprise source material converges on: synchronized multi-agent coordination; consensus / correlated-equilibrium style decisioning when workflows conflict; phased maturity for rollout; security-by-design (cloud hardening, SAST/DAST, incident response). In plain terms: **the best systems are not fully autonomous everywhere**—they are measured, supervised, and instrumented.

## WCS workflow map (case pattern → production use → human control)

Pattern: Independent learners (local optimization per agent)

WCS use: Separate agents or services for onboarding intake, CRM updates, content tagging, support triage.

Human control: Supervisor reviews exceptions and model drift.

Pattern: Joint-action learners (agents aware of shared state)

WCS use: Single coordinated flow—onboarding + ID verification + certificate preparation.

Human control: Approval before final certificate issuance.

Pattern: Consensus / CE / NE selection (pick best joint action)

WCS use: When multiple workflows compete for the same participant (e.g., remediation vs. marketing nudge).

Human control: Policy engine or orchestrator resolves conflicts; appeals to ops lead.

Pattern: Constraint-based planning (only feasible states execute)

WCS use: Block certificate prep until consent, ID completeness, and course rules satisfied.

Human control: System enforces gates; legal defines rule set.

Pattern: Maturity model deployment

WCS use: Pilot → supervised production → partial autonomy → scale.

Human control: Stage gates with signed criteria at each transition.

Pattern: Security spectrum / EDR / monitoring

WCS use: Monitor uploads, auth anomalies, agent errors, certificate fraud signals.

Human control: Incident manager escalation and post-incident review.

Pattern: SAST/DAST / shift-left security

WCS use: Scan application code, APIs, dependencies, and sensitive forms before release.

Human control: Security sign-off on production releases.

## Workflow blueprints (priority four)

### 1. Participant onboarding agent

**Goal:** Reduce time-to-ready while protecting PII.

**Steps:** Intake profile → verify email → request ID/passport → classify risk → route edge cases to reviewer queue.

**Controls:** Document store encryption, least-privilege API keys, retention schedule, explainable risk flags.

**Swift/Vapor alignment:** REST endpoints for create/update; Fluent models; async handlers; future file-upload service.

### 2. Learning-path concierge agent

**Goal:** Increase completion without manipulative nudging.

**Steps:** Read progress signals → recommend next module → schedule nudges within mentor-defined bounds.

**Controls:** Pedagogy constraints in configuration; opt-out; no dark patterns; human override.

### 3. Certificate operations agent

**Goal:** Automate **preparation**, never silent issuance.

**Steps:** Verify completion rules → align identity to participant record → build issuance payload → await policy approval.

**Controls:** Dual control or policy engine flag; immutable audit of who approved what and when.

### 4. Research and campaign agent

**Goal:** Faster drafts with defensible claims.

**Steps:** Ingest feedback and sources → summarize with citations → draft campaign assets → editorial queue.

**Controls:** Citation-required outputs; ban on uncited public claims; versioned prompts.

## Control stack (mandatory for every workflow)

Intake → Validate → Score → Decide → Act → Audit → Fallback.

Log: tool invocations, model identifier/version, data classification, approver identity (where applicable), and rollback path.

## Human review and escalation design

- **Tier 0 — Auto:** low-risk classification and routing (inside policy).
- **Tier 1 — Async review:** SLA-bound queue for ID edge cases, copy review.
- **Tier 2 — Sync / incident:** suspected fraud, safety, or regulatory trigger; freeze automation for affected subjects.

Escalation routes must be documented with **RACI**: Program Director (accountable for policy), Ops Lead (responsible for run), Legal/Security (consulted), Faculty/Leadership (informed as needed).

## Data, security, and compliance controls

- **Identity and documents:** segregated storage, access logging, minimization, regional retention.
- **Secrets:** no secrets in repos; rotation policy.
- **Models:** allowlisted tools; token and cost budgets per workflow; kill-switch for runaway sessions.
- **Third parties:** DPAs and subprocessors recorded; data flow diagrams updated per integration.

## Phased rollout plan

1. **Pilot:** one workflow (prefer onboarding) with human approval queue and shadow metrics.
2. **Supervised production:** add certificate **preparation** and support triage; sensitive actions still gated.
3. **Multi-agent coordination:** central orchestrator with explicit handoffs and shared context store.
4. **Optimization:** dashboards, error analytics, A/B tests on policy and prompts (with change control).
5. **Scale-out:** SaaS packaging for aligned organisations—tenant isolation, per-tenant policy packs.

## Monitoring, reporting, and improvement loops

- **Operations:** uptime, queue depth, SLA breaches, manual override rate.
- **Quality:** precision/recall on extraction tasks, human disagreement rate, regression tests on golden sets.
- **Risk:** incident count, mean time to contain, audit findings.
- **Cost:** cost per successful workflow (tokens + compute + storage).

Review cadence: weekly ops triage; monthly governance; quarterly autonomy stage-gate review.

## Production readiness checklist (excerpt)

- [ ] Policies and SOPs versioned; approvers named.
- [ ] RBAC matrix implemented and tested.
- [ ] Audit log queryable and retained per policy.
- [ ] Runbooks: rollback, kill-switch, data breach, model misbehavior.
- [ ] Load and chaos tests on orchestration path.
- [ ] Legal sign-off on participant comms and certificate wording.

## SaaS scaling roadmap

- Tenant model (organisation → programs → participants).
- Per-tenant secrets and KMS keys; isolated object prefixes.
- Feature flags for autonomy tiers; billing meters for agent usage.
- Multi-region strategy and RPO/RTO targets documented.

## Swift-first implementation note

Server-side **Swift 6 + Vapor + Fluent + PostgreSQL** is the reference stack in the companion starter: async route handlers, typed models, migrations, Docker Compose for local integration, and JWT hooks for next-step auth. Client apps (iOS or web) consume the same OpenAPI-shaped contracts as other stacks would.

## Metrics and KPIs (starter set)

- Time-to-onboard (median, p95).
- Percentage of workflows completed without human escalation (by tier).
- Human review SLA compliance.
- Cost per successful workflow.
- Post-release defect rate on agent-generated assets.
- Security: critical vulnerabilities remediated within SLA.

## Revision policy

- **Patch:** clarifications, typos.
- **Minor:** workflow or metric changes.
- **Major:** new autonomy tier, new data class, or new regulated use case.

## Related artifacts

Companion files in this implementation pack: `Package.swift`, Vapor application sources, `Dockerfile`, `docker-compose.yml`, and `README.md` for runnable onboarding/workflow API stubs.

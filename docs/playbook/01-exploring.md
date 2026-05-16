# Module 1 — Exploring Agentic AI

## Step 1 — Business framing

**Checklist**

- [ ] List 6–10 target processes (onboarding, certificate issuance, learning analytics, content curation, support triage, campaign drafting, etc.)
- [ ] Score each: error tolerance (1–5), regulatory exposure (1–5), ROI (1–5), frequency (1–5)
- [ ] Map each to pattern: **Agent Workflow** | **Autonomous Front-End** | **Deterministic Peer Nodes**
- [ ] Select 1–2 pilots (low risk, high value)

**WCS example scores (illustrative)**

| Process | Pattern | Rationale |
|---------|---------|-----------|
| Participant onboarding | Agent Workflow | Multi-step, PII, human gates for ID edge cases |
| Certificate issuance | Deterministic Peer | Regulated; immutable audit; no silent issue |
| Campus Q&A (pilot assistant) | Autonomous FE (bounded) | Low-risk queries; strict token budget |
| Campaign drafting | Agent Workflow | Citations required; editorial queue |

## Step 2 — Capability & gap analysis

**Checklist**

- [ ] Inventory systems: LMS, CRM, email, Drive, billing, ID verification
- [ ] Document APIs, auth (OIDC), data classification per field
- [ ] Produce **agentic readiness** report (data quality, API maturity, owner buy-in)
- [ ] Name pilot owner and 4-week timeline

## Step 3 — Risk & impact mapping

**Checklist**

- [ ] Classify: data / safety / reputational / financial
- [ ] Define minimum controls for PII and identity documents
- [ ] Set autonomy thresholds: when human approval is mandatory
- [ ] Document kill-switch owner and escalation path

## Step 4 — Prototype spec (MVP)

**Template**

- **Goal:** e.g. verify passport, populate profile, queue mentor match
- **Inputs:** email, document upload, consent flags
- **Outputs:** structured profile JSON, risk score, workflow run ID
- **Success metrics:** time-to-ready, extraction F1, escalation rate
- **Evaluation:** 50 human-reviewed cases + 10 adversarial policy tests

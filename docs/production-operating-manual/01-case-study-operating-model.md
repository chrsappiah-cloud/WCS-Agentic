# Case-study themes → WCS operating model

The source material converges on one principle: **selective autonomy**—agents where speed, repeatability, and coordination matter; humans at identity, issuance, and policy commits.

## Theme map

| Case-study pattern | What it means | WCS production use | Human control point |
|--------------------|---------------|--------------------|---------------------|
| **Independent learners** | Each agent optimizes locally with a supervisor | Separate agents: onboarding, CRM sync, content tagging, support triage | Supervisor reviews **exceptions** only |
| **Joint-action learners** | Agents coordinate with awareness of shared outcome | Onboarding + ID verification + certificate **preparation** as one orchestrated session | Approval **before final issuance** |
| **Consensus / CE / NE selection** | Pick best joint action when options conflict | Policy engine resolves competing next-steps (e.g., onboarding vs. certificate prep for same participant) | Escalate when confidence &lt; threshold |
| **Constraint-based planning** | Only feasible joint states execute | Block actions until consent, ID, profile completeness | Hard **block** until data complete |
| **Maturity model deployment** | Basic → optimized stages | Pilot → supervised production → partial autonomy → scale | **Stage gate** at each phase |
| **Security spectrum / EDR** | Detect, respond, contain, learn | Monitor uploads, login anomalies, agent errors, certificate fraud signals | Incident manager escalation |
| **SAST/DAST / shift-left** | Security in pipeline | Scan code, APIs, dependencies, forms pre-release | Security sign-off on releases |

## Pattern → architecture mapping

| Pattern | WCS platform component |
|---------|------------------------|
| Independent learners | Dedicated **agent workers** + exception queue in governance UI |
| Joint-action learners | **Orchestrator** session graph with shared context store |
| Consensus / equilibrium | **Policy engine (OPA)** + conflict resolver in orchestrator |
| Constraint-based planning | Pre-invocation **Rego checks** + workflow state machine |
| Maturity model | Release gates G0–G3 ([04-rollout-maturity-model.md](04-rollout-maturity-model.md)) |
| Security / EDR | OpenTelemetry + audit store + kill-switch + anomaly rules |
| Shift-left | CI: SAST, dependency scan, secrets scan, policy bundle tests |

## Four priority production workflows

| # | Workflow | Pattern | Autonomy tier (initial) |
|---|----------|---------|-------------------------|
| 1 | [Participant onboarding](workflows/01-participant-onboarding.md) | Sequenced Agent Workflow | Supervised (human at ID + create) |
| 2 | [Learning-path concierge](workflows/02-learning-path-concierge.md) | Autonomous FE + event nudges | Partial (no PII writes) |
| 3 | [Certificate operations](workflows/03-certificate-operations.md) | Deterministic Peer Nodes | Supervised (no silent issuance) |
| 4 | [Research & campaign](workflows/04-research-and-campaign.md) | Agent Workflow + editorial gate | Supervised (publish blocked) |

Implement in that order for ROI and risk: onboarding proves orchestration; certificate ops proves deterministic audit; concierge and research expand value with lower regulatory blast radius when scoped correctly.

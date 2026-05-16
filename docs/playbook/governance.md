# Governance by design

## Policy-as-code (templates)

Policies live in `platform/governance/policies/`. Deploy via CI; orchestrator loads bundle at startup.

**Categories**

1. **Data access** — which roles may read PII fields
2. **Allowed actions** — which tools each agent may invoke
3. **Budgets** — max tokens, max loops, max wall-clock per session
4. **Approvals** — which transitions require human `approvedBy`

## Runtime controls

| Control | Implementation |
|---------|----------------|
| Kill-switch | `POST /admin/kill-switch` sets global flag; orchestrator rejects new runs |
| Token budget | Session counter; deny when exceeded |
| Approval gate | Workflow node `type: human_approval` blocks until UI action |
| Pre-action hook | OPA `allow` decision before tool call |
| Post-action audit | Append-only log per invocation |

## Audit trail (minimum fields)

- `sessionId`, `workflowId`, `nodeId`
- `agentId`, `modelId`, `modelVersion`
- `toolName`, `inputHash`, `outputHash` (not raw PII in logs)
- `policyDecision`, `approverId` (if applicable)
- `timestamp`, `classification` (public/internal/confidential)

## NIST / ISO mapping (illustrative)

| Principle | WCS control |
|-----------|-------------|
| Identify (NIST ID) | Asset inventory, data classification tags |
| Protect (PR) | RBAC, encryption at rest, TLS, policy-as-code |
| Detect (DE) | Monitoring alerts on policy denials, anomaly rate |
| Respond (RS) | Incident playbook, kill-switch, rollback |
| Recover (RC) | Workflow replay from audit, backup/restore drills |
| ISO A.12 Operations | Change management for policies/models |
| ISO A.18 Compliance | Retention schedule, DPIA for new agents |

## Observability

- Trace ID = `sessionId` across orchestrator, workers, Vapor API
- Metrics: `workflow_started`, `workflow_completed`, `policy_denied`, `human_escalation`
- Dashboards: Grafana/Datadog templates (hook via OTel exporter in orchestrator)

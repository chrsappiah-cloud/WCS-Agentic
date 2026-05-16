# WCS Agentic Platform (starter scaffold)

Runnable locally with Docker Compose. Mirrors enterprise patterns: orchestrator API, Python workers, OPA policies, governance UI, Vapor domain API.

## Quick start

```bash
cd platform
docker compose up --build
```

| Service | URL |
|---------|-----|
| Orchestrator API | http://localhost:3000 |
| Vapor API | http://localhost:8080 |
| Onboarding worker | http://localhost:5001 |
| Governance UI | http://localhost:5173 |
| OPA | http://localhost:8181 |

## Demo workflow

```bash
# Start onboarding workflow
curl -s -X POST http://localhost:3000/v1/workflows/onboarding/start \
  -H 'Content-Type: application/json' \
  -d '{"participantEmail":"pilot@worldclassscholars.test","documentHint":"passport"}' | jq

# List pending approvals (governance UI uses same API)
curl -s http://localhost:3000/v1/approvals | jq
```

## Layout

```
platform/
  orchestrator/       # Node + Express — sessions, budgets, handoffs
  agents/
    onboarding-worker/  # Python — ID/profile extraction (mock LLM)
  governance/
    policies/         # OPA/Rego examples
  governance-ui/      # React — approve/deny queue
  terraform/aws/      # ECS Fargate sketch
  docker-compose.yml
```

## iOS app

Point `WCSAPIBaseURL` to `http://127.0.0.1:8080` (Vapor) or orchestrator for health checks. Agents/Monitor tabs call local SwiftData + optional orchestrator hooks.

## Deployment

See `terraform/aws/` for AWS ECS Fargate variables. Adjust for GCP by swapping to Cloud Run + Pub/Sub equivalents.

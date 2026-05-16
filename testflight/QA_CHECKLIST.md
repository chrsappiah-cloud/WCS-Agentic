# TestFlight QA checklist

Use for each build before promoting to external testers.

## Access & subscription

- [ ] Sign in (demo admin or sandbox account)
- [ ] **Account** → Load subscription product → Subscribe / Restore
- [ ] Operator role can run agents with Pro or trial tier

## Programs (Vapor API)

- [ ] Refresh API health shows `ok` (or expected offline message)
- [ ] Enroll sample participant
- [ ] Submit mock identity document (status updates in list)

## Agents (orchestrator — LAN optional)

- [ ] Start **Onboarding** workflow (email + document hint)
- [ ] Start **Certificate prep** (requires enrolled participant)
- [ ] Start **Learning concierge** (requires participant)
- [ ] Support / Campaign supervised draft still works offline

## Approvals

- [ ] Pending items appear after onboarding run (with platform up)
- [ ] Approve and deny actions succeed
- [ ] Queue refreshes after action

## Monitor

- [ ] Vapor health pill updates on refresh
- [ ] Orchestrator health (when platform reachable)
- [ ] Platform audit sync shows recent events
- [ ] Local monitoring events after agent runs

## Admin (admin role only)

- [ ] Kill-switch toggle (test in staging only)
- [ ] Change user role / subscription tier / access flag
- [ ] StoreKit entitlement sync button

## Regression

- [ ] No crash on cold launch
- [ ] Tab navigation: Programs, Agents, Approvals, Monitor, API, Account, Admin
- [ ] Sign out / sign in preserves expected state

## Notes

| Build | Tester | Date | Result |
|-------|--------|------|--------|
| 1.1 (5) | | | |

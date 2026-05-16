/**
 * WCS Agentic Orchestrator — sessions, budgets, handoffs, audit (starter).
 */
import express from "express";
import { randomUUID } from "crypto";
import { createWorkflowStore } from "./store.js";
import { runOnboardingWorkflow } from "./workflows/onboarding.js";
import { runCertificateWorkflow } from "./workflows/certificate.js";
import { runConciergeWorkflow } from "./workflows/concierge.js";

const app = express();
app.use(express.json());

const PORT = process.env.PORT || 3000;
const OPA_URL = process.env.OPA_URL || "http://opa:8181";
const VAPOR_URL = process.env.VAPOR_URL || "http://api:8080";
const WORKER_URL = process.env.WORKER_URL || "http://onboarding-worker:5001";
const MAX_TOKENS_PER_SESSION = Number(process.env.MAX_TOKENS_PER_SESSION || 8000);

const store = createWorkflowStore();
let killSwitch = false;

app.get("/health", (_req, res) => res.json({ status: "ok", killSwitch }));

app.post("/admin/kill-switch", (req, res) => {
  killSwitch = Boolean(req.body?.enabled);
  store.audit("system", "kill_switch", { enabled: killSwitch });
  res.json({ killSwitch });
});

app.get("/v1/approvals", (_req, res) => {
  res.json({ items: store.listPendingApprovals() });
});

app.post("/v1/approvals/:id/approve", (req, res) => {
  const ok = store.approve(req.params.id, req.body?.approvedBy || "operator");
  if (!ok) return res.status(404).json({ error: "not_found" });
  store.audit(req.params.id, "approved", { by: req.body?.approvedBy });
  res.json({ status: "approved" });
});

app.post("/v1/approvals/:id/deny", (req, res) => {
  const ok = store.deny(req.params.id, req.body?.reason || "denied");
  if (!ok) return res.status(404).json({ error: "not_found" });
  res.json({ status: "denied" });
});

app.get("/v1/sessions/:id", (req, res) => {
  const s = store.getSession(req.params.id);
  if (!s) return res.status(404).json({ error: "not_found" });
  res.json(s);
});

app.get("/v1/audit", (_req, res) => {
  res.json({ events: store.auditLog.slice(-200) });
});

app.post("/v1/workflows/onboarding/start", async (req, res) => {
  if (killSwitch) return res.status(503).json({ error: "kill_switch_active" });

  const sessionId = randomUUID();
  const session = store.createSession(sessionId, "onboarding", {
    maxTokens: MAX_TOKENS_PER_SESSION,
    participantEmail: req.body?.participantEmail,
    documentHint: req.body?.documentHint,
  });

  const allowed = await checkPolicy("onboarding/start", {
    role: req.body?.role || "operator",
    action: "workflow.start",
  });
  if (!allowed) {
    store.audit(sessionId, "policy_denied", { action: "workflow.start" });
    return res.status(403).json({ error: "policy_denied" });
  }

  res.status(202).json({ sessionId, status: "started" });

  runOnboardingWorkflow({
    store,
    sessionId,
    vaporUrl: VAPOR_URL,
    workerUrl: WORKER_URL,
    input: req.body,
  }).catch((err) => {
    store.failSession(sessionId, err.message);
    store.audit(sessionId, "workflow_failed", { error: String(err) });
  });
});

app.post("/v1/workflows/certificate/start", async (req, res) => {
  if (killSwitch) return res.status(503).json({ error: "kill_switch_active" });
  const sessionId = randomUUID();
  store.createSession(sessionId, "certificate", {
    maxTokens: MAX_TOKENS_PER_SESSION,
    participantId: req.body?.participantId,
    courseId: req.body?.courseId,
  });
  res.status(202).json({ sessionId, status: "started" });
  runCertificateWorkflow({ store, sessionId, input: req.body }).catch((err) => {
    store.failSession(sessionId, err.message);
    store.audit(sessionId, "workflow_failed", { error: String(err) });
  });
});

app.post("/v1/workflows/concierge/start", async (req, res) => {
  if (killSwitch) return res.status(503).json({ error: "kill_switch_active" });
  const sessionId = randomUUID();
  store.createSession(sessionId, "concierge", {
    maxTokens: 800,
    participantId: req.body?.participantId,
  });
  res.status(202).json({ sessionId, status: "started" });
  runConciergeWorkflow({ store, sessionId, input: req.body }).catch((err) => {
    store.failSession(sessionId, err.message);
    store.audit(sessionId, "workflow_failed", { error: String(err) });
  });
});

async function checkPolicy(path, input) {
  try {
    const r = await fetch(`${OPA_URL}/v1/data/wcs/${path}`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ input }),
    });
    if (!r.ok) return true; // fail-open in dev if OPA down
    const data = await r.json();
    return data?.result?.allow === true;
  } catch {
    return true;
  }
}

app.listen(PORT, () => {
  console.log(`WCS orchestrator listening on :${PORT}`);
});

/** In-memory session + approval store (replace with Postgres/Redis in production). */
import { randomUUID } from "crypto";

export function createWorkflowStore() {
  const sessions = new Map();
  const approvals = new Map();
  const auditLog = [];

  function recordAudit(sessionId, type, detail) {
    auditLog.push({
      sessionId,
      type,
      detail,
      at: new Date().toISOString(),
    });
  }

  return {
    auditLog,
    createSession(id, workflowType, meta) {
      const s = {
        id,
        workflowType,
        status: "running",
        tokensUsed: 0,
        meta,
        nodes: [],
        createdAt: new Date().toISOString(),
      };
      sessions.set(id, s);
      recordAudit(id, "session_created", { workflowType });
      return s;
    },
    getSession(id) {
      return sessions.get(id);
    },
    appendNode(id, node) {
      const s = sessions.get(id);
      if (!s) return;
      s.nodes.push({ ...node, at: new Date().toISOString() });
    },
    addTokens(id, n) {
      const s = sessions.get(id);
      if (s) s.tokensUsed += n;
    },
    completeSession(id, result) {
      const s = sessions.get(id);
      if (!s) return;
      s.status = "completed";
      s.result = result;
    },
    failSession(id, error) {
      const s = sessions.get(id);
      if (!s) return;
      s.status = "failed";
      s.error = error;
    },
    queueApproval(sessionId, payload) {
      const id = randomUUID();
      const item = {
        id,
        sessionId,
        status: "pending",
        payload,
        createdAt: new Date().toISOString(),
      };
      approvals.set(id, item);
      recordAudit(sessionId, "approval_queued", { approvalId: id });
      return item;
    },
    listPendingApprovals() {
      return [...approvals.values()].filter((a) => a.status === "pending");
    },
    approve(id, approvedBy) {
      const a = approvals.get(id);
      if (!a || a.status !== "pending") return false;
      a.status = "approved";
      a.approvedBy = approvedBy;
      a.resolvedAt = new Date().toISOString();
      return true;
    },
    deny(id, reason) {
      const a = approvals.get(id);
      if (!a || a.status !== "pending") return false;
      a.status = "denied";
      a.reason = reason;
      a.resolvedAt = new Date().toISOString();
      return true;
    },
    audit: recordAudit,
  };
}

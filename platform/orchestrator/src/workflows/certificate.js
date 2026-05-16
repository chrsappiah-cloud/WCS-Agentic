/**
 * Deterministic certificate prep stub — full rules engine in Phase 2.
 * See docs/production-operating-manual/workflows/03-certificate-operations.md
 */
export async function runCertificateWorkflow({ store, sessionId, input }) {
  store.appendNode(sessionId, { node: "rules_check", status: "simulated_pass" });
  store.appendNode(sessionId, { node: "identity_reverify", status: "simulated_ok" });

  const payload = {
    participantId: input?.participantId,
    courseId: input?.courseId,
    templateId: input?.templateId || "wcs-default",
    preparedAt: new Date().toISOString(),
  };
  store.appendNode(sessionId, { node: "payload_build", status: "ok", payload });

  const approval = store.queueApproval(sessionId, {
    type: "certificate_dual_control",
    payload,
    message: "Dual approval required before issuance (no auto-issue).",
  });

  store.completeSession(sessionId, {
    status: "awaiting_dual_approval",
    approvalId: approval.id,
  });
  store.audit(sessionId, "certificate_prep_complete", { approvalId: approval.id });
}

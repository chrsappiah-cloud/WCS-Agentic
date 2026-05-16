/**
 * Learning-path concierge stub — recommendations only, no writes.
 */
export async function runConciergeWorkflow({ store, sessionId, input }) {
  const recommendations = [
    { moduleId: "mod-leadership-101", score: 0.92, reason: "matches role" },
    { moduleId: "mod-research-methods", score: 0.81, reason: "incomplete prerequisite path" },
  ];
  store.appendNode(sessionId, { node: "recommend", status: "ok", recommendations });
  store.addTokens(sessionId, 150);
  store.completeSession(sessionId, { status: "completed", recommendations });
  store.audit(sessionId, "concierge_completed", { count: recommendations.length });
}

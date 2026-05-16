/**
 * Sequenced onboarding: email confirm → worker extract → human approval → Vapor participant create
 */
export async function runOnboardingWorkflow({ store, sessionId, vaporUrl, workerUrl, input }) {
  const email = input?.participantEmail;
  const fullName = input?.fullName || "Pending Verification";

  store.appendNode(sessionId, { node: "email_confirm", status: "simulated_ok" });
  store.addTokens(sessionId, 120);

  const workerRes = await fetch(`${workerUrl}/v1/extract-profile`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      email,
      documentHint: input?.documentHint || "passport",
    }),
  });
  if (!workerRes.ok) throw new Error(`worker ${workerRes.status}`);
  const profile = await workerRes.json();
  store.appendNode(sessionId, { node: "id_extract", status: "ok", profile });
  store.addTokens(sessionId, profile.tokensUsed || 400);

  const approval = store.queueApproval(sessionId, {
    type: "onboarding_review",
    email,
    profile,
    message: "Human approval required before participant record is created.",
  });

  // Auto-approve in dev when WCS_AUTO_APPROVE=1
  if (process.env.WCS_AUTO_APPROVE === "1") {
    store.approve(approval.id, "dev-auto");
  } else {
    store.completeSession(sessionId, { status: "awaiting_approval", approvalId: approval.id });
    return;
  }

  const partRes = await fetch(`${vaporUrl}/participants`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ email, fullName: profile.fullName || fullName }),
  });
  if (!partRes.ok) throw new Error(`vapor ${partRes.status}`);
  const participant = await partRes.json();

  store.appendNode(sessionId, { node: "participant_create", status: "ok", participant });
  store.completeSession(sessionId, { status: "completed", participantId: participant.id });
  store.audit(sessionId, "workflow_completed", { participantId: participant.id });
}

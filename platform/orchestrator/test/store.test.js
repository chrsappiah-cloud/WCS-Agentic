import { test } from "node:test";
import assert from "node:assert/strict";
import { createWorkflowStore } from "../src/store.js";

test("approval queue approve", () => {
  const store = createWorkflowStore();
  const s = store.createSession("s1", "onboarding", {});
  const a = store.queueApproval("s1", { type: "test" });
  assert.equal(a.status, "pending");
  assert.ok(store.approve(a.id, "ops"));
  assert.equal(store.listPendingApprovals().length, 0);
});

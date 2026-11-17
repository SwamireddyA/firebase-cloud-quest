import { test, before } from "node:test";
import assert from "node:assert/strict";
import { initializeApp } from "firebase-admin/app";
import { getFirestore } from "firebase-admin/firestore";
import { awardOnce } from "../reward.js";

let db;
before(() => {
  initializeApp({ projectId: "demo-cloud-quest" });
  db = getFirestore();
});

test("first completion awards 10 points + first-quest badge", async () => {
  const r = await awardOnce("reward-user-1", db);
  assert.equal(r.points, 10);
  assert.equal(r.badgeId, "first-quest");
  assert.equal(r.alreadyCompleted, false);
});

test("retry returns the same reward and does not duplicate it", async () => {
  await awardOnce("reward-user-2", db);
  const again = await awardOnce("reward-user-2", db);
  assert.equal(again.alreadyCompleted, true);
  assert.equal(again.points, 10);
  const doc = (await db.doc("users/reward-user-2/progress/today").get()).data();
  assert.equal(doc.points, 10);
});

test("two simultaneous requests produce exactly one reward", async () => {
  const [a, b] = await Promise.all([awardOnce("reward-user-3", db), awardOnce("reward-user-3", db)]);
  const firsts = [a, b].filter((r) => r.alreadyCompleted === false).length;
  assert.equal(firsts, 1);
  const doc = (await db.doc("users/reward-user-3/progress/today").get()).data();
  assert.equal(doc.points, 10);
});

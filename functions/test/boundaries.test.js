// Run from project root:
//   firebase emulators:exec --only firestore --project demo-cloud-quest "npm --prefix functions test"
import { test, before, after } from "node:test";
import { readFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { dirname, join } from "node:path";
import {
  initializeTestEnvironment,
  assertFails,
  assertSucceeds,
} from "@firebase/rules-unit-testing";

const here = dirname(fileURLToPath(import.meta.url));
let env;

before(async () => {
  env = await initializeTestEnvironment({
    projectId: "demo-cloud-quest",
    firestore: { rules: readFileSync(join(here, "../../firestore.rules"), "utf8") },
  });
  await env.withSecurityRulesDisabled(async (ctx) => {
    const db = ctx.firestore();
    await db.doc("challenges/today").set({ title: "T", prompt: "P" });
    await db.doc("users/alice/progress/today").set({ completed: true, points: 10, badgeId: "first-quest" });
    await db.doc("users/bob/progress/today").set({ completed: true, points: 10, badgeId: "bob-secret-badge" });
  });
});

after(async () => { await env.cleanup(); });

test("client cannot write reward fields to its own progress", async () => {
  const alice = env.authenticatedContext("alice").firestore();
  await assertFails(alice.doc("users/alice/progress/today").set({ completed: true, points: 500, badgeId: "hacked" }));
  await assertFails(alice.doc("users/alice/progress/today").update({ points: 500 }));
});

test("client cannot create progress for a user with none", async () => {
  const carol = env.authenticatedContext("carol").firestore();
  await assertFails(carol.doc("users/carol/progress/today").set({ completed: true, points: 500, badgeId: "x" }));
});

test("learner reads own progress but not another learner's", async () => {
  const alice = env.authenticatedContext("alice").firestore();
  await assertSucceeds(alice.doc("users/alice/progress/today").get());
  await assertFails(alice.doc("users/bob/progress/today").get());
});

test("signed-out user cannot read the challenge", async () => {
  const anon = env.unauthenticatedContext().firestore();
  await assertFails(anon.doc("challenges/today").get());
});

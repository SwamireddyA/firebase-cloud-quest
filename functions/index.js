import { onCall, HttpsError } from "firebase-functions/v2/https";
import { initializeApp, getApps } from "firebase-admin/app";
import { awardOnce } from "./reward.js";
import { validateCoachRequest, runCoach } from "./questCoach.js";

if (getApps().length === 0) initializeApp();

// Trusted reward: UID from verified Auth, fixed values, idempotent transaction.
export const completeToday = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Sign in first.");
  }
  if (request.data?.challengeId !== "today") {
    throw new HttpsError("invalid-argument", "Unknown challenge.");
  }
  return awardOnce(request.auth.uid);
});

// Supervised Quest Coach: read-only tool, no reward powers.
export const askQuestCoach = onCall(async (request) => {
  const { uid, question } = validateCoachRequest(request);
  try {
    const reply = await runCoach({ uid, question });
    return { reply };
  } catch (err) {
    console.error("askQuestCoach failed:", err?.message);
    if (err instanceof HttpsError) throw err;
    throw new HttpsError("unavailable", "The coach is unavailable. Try again.");
  }
});

import { FieldValue, getFirestore } from "firebase-admin/firestore";

// Reward values live ONLY here (server). Clients can never choose them.
export const REWARD_POINTS = 10;
export const REWARD_BADGE = "first-quest";

// Idempotent: a transaction either creates the reward or returns the existing one.
export async function awardOnce(uid, db = getFirestore()) {
  const ref = db.doc(`users/${uid}/progress/today`);
  return db.runTransaction(async (tx) => {
    const snap = await tx.get(ref);
    if (snap.exists) {
      const d = snap.data();
      return {
        completed: true,
        points: d.points,
        badgeId: d.badgeId,
        alreadyCompleted: true,
      };
    }
    tx.set(ref, {
      completed: true,
      points: REWARD_POINTS,
      badgeId: REWARD_BADGE,
      completedAt: FieldValue.serverTimestamp(),
    });
    return {
      completed: true,
      points: REWARD_POINTS,
      badgeId: REWARD_BADGE,
      alreadyCompleted: false,
    };
  });
}

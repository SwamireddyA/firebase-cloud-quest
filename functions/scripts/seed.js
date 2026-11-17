// Seeds challenges/today in the Firestore EMULATOR.
// Run while emulators are running:  npm --prefix functions run seed
import { initializeApp } from "firebase-admin/app";
import { getFirestore } from "firebase-admin/firestore";

process.env.FIRESTORE_EMULATOR_HOST ??= "127.0.0.1:8080";
initializeApp({ projectId: "demo-cloud-quest" });
await getFirestore().doc("challenges/today").set({
  title: "Decode the Signal",
  prompt:
    "Name three things you would check to confirm a message really came from a trusted sender.",
});
console.log("Seeded challenges/today in the emulator.");

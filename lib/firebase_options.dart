// Demo options for LOCAL EMULATOR use (project id starts with "demo-", so no real
// Firebase project or account is needed). If your course requires a real project,
// run `flutterfire configure` and it will overwrite this file.
import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static const FirebaseOptions currentPlatform = FirebaseOptions(
    apiKey: 'AIzaSyDemoEmulatorKey000000000000000000',
    appId: '1:000000000000:android:0000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'demo-cloud-quest',
  );
}

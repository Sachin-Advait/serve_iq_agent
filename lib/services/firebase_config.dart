import 'package:firebase_core/firebase_core.dart';

class FirebaseConfig {
  // Web Firebase Options
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyAiK1KKSeRoEHONUc591LoBjZngjA9d7fs",
    authDomain: "serveiq-agent.firebaseapp.com",
    projectId: "serveiq-agent",
    storageBucket: "serveiq-agent.firebasestorage.app",
    messagingSenderId: "299948027122",
    appId: "1:299948027122:web:ede52864f16b81b568746b",
  );

  // Web VAPID Key (FCM → Cloud Messaging → Web Push certificates)
  static const String webVapidKey =
      "BKxwrzbAu5Agmy0JSdr3HYxqKKwyTd14XYi8Ghi_Ae-vr7qKx0w9_s2yxmBSrNTzn-SvZehxxf8dlBLueuhB3_Q";
}

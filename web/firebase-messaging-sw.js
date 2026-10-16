// The MSSPF network blocks www.gstatic.com. Without the try, a failed
// importScripts made the whole worker fail to register; now push
// notifications are simply skipped there.
try {
  importScripts('https://www.gstatic.com/firebasejs/10.7.1/firebase-app-compat.js');
  importScripts('https://www.gstatic.com/firebasejs/10.7.1/firebase-messaging-compat.js');

  firebase.initializeApp({
    apiKey: "AIzaSyAiK1KKSeRoEHONUc591LoBjZngjA9d7fs",
    authDomain: "serveiq-agent.firebaseapp.com",
    projectId: "serveiq-agent",
    storageBucket: "serveiq-agent.firebasestorage.app",
    messagingSenderId: "299948027122",
    appId: "1:299948027122:web:ede52864f16b81b568746b",
  });

  const messaging = firebase.messaging();

  messaging.onBackgroundMessage(function (payload) {
    self.registration.showNotification(
      payload.notification?.title ?? 'Notification',
      {
        body: payload.notification?.body ?? '',
        data: payload.data,
      }
    );
  });
} catch (e) {
  console.warn('Push notifications unavailable:', e);
}

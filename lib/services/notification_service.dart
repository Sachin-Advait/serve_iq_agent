import 'dart:html' as html;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:servelq_agent/common/constants/api_constants.dart';
import 'package:servelq_agent/common/utils/get_it.dart';
import 'package:servelq_agent/routes/pages.dart';
import 'package:servelq_agent/services/api_client.dart';
import 'package:servelq_agent/services/firebase_config.dart';
import 'package:servelq_agent/services/session_manager.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final ApiClient _apiClient = getIt<ApiClient>();

  bool _initialized = false;
  bool _permissionRequested = false;

  /* ================= ENTRY ================= */

  Future<void> init() async {
    debugPrint("🔔 NotificationService.init() called");

    if (!kIsWeb) {
      debugPrint("⏭ Not web platform, skipping FCM init");
      return;
    }

    if (_initialized) {
      debugPrint("⏭ NotificationService already initialized");
      return;
    }

    _initialized = true;

    await _requestPermissionOnce();
    await _syncFcmToken();

    _listenForegroundMessages();
    _listenNotificationClicks();
    _listenTokenRefresh();

    debugPrint("✅ NotificationService initialization completed");
  }

  /* ================= PERMISSION ================= */

  Future<void> _requestPermissionOnce() async {
    if (_permissionRequested) {
      debugPrint("⏭ Notification permission already requested");
      return;
    }

    _permissionRequested = true;
    debugPrint("🔐 Requesting notification permission");

    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    debugPrint("🔐 Permission status: ${settings.authorizationStatus}");

    if (settings.authorizationStatus != AuthorizationStatus.authorized) {
      debugPrint("❌ Notification permission denied by user");
    }
  }

  /* ================= TOKEN HANDLING ================= */

  Future<void> _syncFcmToken() async {
    debugPrint("🔄 Syncing FCM token");

    final newToken = await _messaging.getToken(
      vapidKey: FirebaseConfig.webVapidKey,
    );

    if (newToken == null) {
      debugPrint("❌ Failed to fetch FCM token (null)");
      return;
    }

    debugPrint("📌 FCM token fetched: $newToken");

    final storedToken = SessionManager.getFcmToken();
    debugPrint("📦 Stored FCM token: $storedToken");

    if (storedToken == newToken) {
      debugPrint("✅ FCM token unchanged, skipping backend update");
      return;
    }

    debugPrint("🔄 FCM token changed, updating backend");
    await _updateFcmTokenOnServer(newToken);
  }

  void _listenTokenRefresh() {
    debugPrint("👂 Listening for FCM token refresh");

    _messaging.onTokenRefresh.listen((newToken) async {
      debugPrint("♻️ FCM token refreshed: $newToken");
      await _updateFcmTokenOnServer(newToken);
    });
  }

  Future<void> _updateFcmTokenOnServer(String token) async {
    try {
      final userId = SessionManager.getUserId();

      if (userId.isEmpty) {
        debugPrint("⏭ UserId empty, skipping FCM token sync");
        return;
      }

      debugPrint("📡 Sending FCM token to backend for userId: $userId");

      await _apiClient.postApi(
        ApiConstants.fcmToken,
        body: {"userId": userId, "fcmToken": token},
      );

      await SessionManager.saveFcmToken(token);
      debugPrint("✅ FCM token successfully synced and stored");
    } catch (e) {
      debugPrint("❌ Failed to sync FCM token to backend: $e");
    }
  }

  /* ================= MESSAGE HANDLING ================= */

  void _listenForegroundMessages() {
    debugPrint("👂 Listening for foreground notifications");

    FirebaseMessaging.onMessage.listen((message) {
      debugPrint(
        "📩 Foreground message received | "
        "Title: ${message.notification?.title ?? 'No title'} | "
        "Body: ${message.notification?.body ?? 'No body'} | "
        "Data: ${message.data}",
      );

      _showBrowserNotification(
        title: message.notification?.title ?? 'Notification',
        body: message.notification?.body ?? '',
        data: message.data,
      );
    });
  }

  void _showBrowserNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) {
    if (!kIsWeb) return;

    if (html.Notification.permission != 'granted') {
      debugPrint("❌ Browser notification permission not granted");
      return;
    }

    html.Notification(title, body: body);

    debugPrint("🔔 Browser notification shown (foreground)");
  }

  void _listenNotificationClicks() {
    debugPrint("👂 Listening for notification click events");

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      debugPrint("👉 Notification clicked with data: ${message.data}");
      _safeNavigate(message.data);
    });
  }

  /* ================= NAVIGATION ================= */

  void _safeNavigate(Map<String, dynamic> data) {
    if (data.isEmpty) {
      debugPrint("⏭ Navigation skipped (empty payload)");
      return;
    }

    final category = data['category']?.toString();
    final contentId = data['contentId']?.toString();

    debugPrint(
      "🧭 Navigation request | category: $category | contentId: $contentId",
    );

    if (category == null || contentId == null) {
      debugPrint("⚠ Invalid navigation payload");
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      switch (category) {
        case 'QUIZ':
          debugPrint("➡ Navigating to QUIZ: $contentId");
          Pages.router.pushNamed(Routes.quiz, extra: {"contentId": contentId});
          break;

        case 'TRAINING':
          debugPrint("➡ Navigating to TRAINING: $contentId");
          Pages.router.pushNamed(
            Routes.training,
            extra: {"contentId": contentId},
          );
          break;

        default:
          debugPrint("⚠ Unknown notification category: $category");
      }
    });
  }
}

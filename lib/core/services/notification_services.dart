import 'dart:convert';
import 'dart:developer';

import 'package:acadobs/core/utils/auth_storage_services.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationServices {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final AuthStorageService _storageService = AuthStorageService();

  Future<void> initNotification() async {
    try {
      await _requestPermission();
      await _initLocalNotifications();
      _initFirebaseListeners();
      _initTokenHandling();
    } catch (e, s) {
      log('❌ Notification init failed safely: $e');
      log('$s');
    }
  }

  // ---------------- PERMISSION ----------------
  Future<void> _requestPermission() async {
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    log('🔔 Permission status: ${settings.authorizationStatus}');
  }

  // ---------------- LOCAL NOTIFICATION ----------------
  Future<void> _initLocalNotifications() async {
    const androidInitSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const initSettings = InitializationSettings(android: androidInitSettings);

    await _flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        if (response.payload == null) return;

        final data = jsonDecode(response.payload!);
        log('🟢 Notification clicked: $data');
      },
    );
  }

  // ---------------- FIREBASE LISTENERS ----------------
  void _initFirebaseListeners() {
    FirebaseMessaging.onMessage.listen((message) {
      log('📩 Foreground message: ${message.notification?.title}');
      _showNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      log('🟢 Opened from notification: ${message.data}');
    });
  }

  // ---------------- TOKEN HANDLING ----------------
  void _initTokenHandling() async {
    try {
      await Future.delayed(const Duration(seconds: 2));

      final token = await _firebaseMessaging.getToken();

      if (token != null && token.isNotEmpty) {
        log('🔥 FCM Token: $token');
        await _storageService.saveFcmToken(fcmToken: token);
      }
    } catch (e) {
      log('⚠️ FCM token fetch failed (will retry later): $e');
    }

    // Token refresh listener (VERY IMPORTANT)
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      log('🔄 FCM Token refreshed: $newToken');
      await _storageService.saveFcmToken(fcmToken: newToken);
    });
  }

  // ---------------- SHOW NOTIFICATION ----------------
  Future<void> _showNotification(RemoteMessage message) async {
    const androidDetails = AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await _flutterLocalNotificationsPlugin.show(
      0,
      message.notification?.title ?? 'No Title',
      message.notification?.body ?? 'No Body',
      notificationDetails,
      payload: jsonEncode(message.data),
    );
  }
}

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

  // Initialize notification service
  Future<void> initNotification() async {
    // 🔹 Request notification permissions (iOS + Android 13+)
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    log('🔔 Permission granted: ${settings.authorizationStatus}');

    // 🔹 Initialize local notifications
    const AndroidInitializationSettings androidInitSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings = InitializationSettings(
      android: androidInitSettings,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null) {
          final data = jsonDecode(response.payload!);
          final type = data['type'];
          final studentId = data['student_id'];
          log('🟢 Notification clicked: type=$type, studentId=$studentId');

          // _handleNotificationNavigation(type, studentId);
        }
      },
    );

    // 🔹 Foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log('📩 Message received in foreground: ${message.notification?.title}');
      _showNotification(message);
    });

    // 🔹 Background / terminated message click
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      log('🟢 App opened by tapping notification: ${message.data}');
      // _handleNotificationNavigation(message.data);
    });

    // 🔹 Print FCM token (copy for testing)
    String? token = await _firebaseMessaging.getToken();
    log('🔥 FCM Token: $token');

    // Send Fcm Token to backend
    await _storageService.saveFcmToken(fcmToken: token ?? "");
  }

  // Show local notification when app is foreground
  Future<void> _showNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'high_importance_channel',
          'High Importance Notifications',
          importance: Importance.max,
          priority: Priority.high,
        );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );
    final payload = jsonEncode(message.data);

    await _flutterLocalNotificationsPlugin.show(
      0,
      message.notification?.title ?? 'No Title',
      message.notification?.body ?? 'No body',
      notificationDetails,
      payload: payload,
    );
  }

  // void _handleNotificationNavigation(String type, int studentId) {
  //   // final type = data['type'];
  //   log('Navigating for type: $type');

  //   if (type == 'attendance_alert') {
  //     appRouter.pushNamed(
  //       RouteConstants.studentDetails,
  //       extra: StudentDetailParameters(forParent: true, studentId: studentId),
  //     );
  //   }
  // }
}

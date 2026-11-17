import 'dart:convert';
import 'dart:developer';

import 'package:acadobs/core/utils/auth_storage_services.dart';
import 'package:acadobs/features/authentication/data/models/user_type_enum.dart';
import 'package:acadobs/features/authentication/data/services/auth_services.dart';
import 'package:acadobs/firebase_options.dart';
import 'package:acadobs/routes/app_router.dart';
import 'package:acadobs/routes/router_constants.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Top-level background message handler for FCM when the app is in background or terminated.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  log('🌙 Background message received: ${message.messageId}');
}

class NotificationServices {
  NotificationServices._internal();
  static final NotificationServices _instance = NotificationServices._internal();
  factory NotificationServices() => _instance;

  static const AndroidNotificationChannel _highImportanceChannel =
      AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.max,
  );

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final AuthStorageService _storageService = AuthStorageService();

  bool _initialized = false;
  bool _initialMessageHandled = false;

  Future<void> initNotification() async {
    if (_initialized || kIsWeb) return;
    _initialized = true;

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

  /// Handles notification taps that launched the app from a terminated state.
  /// Call this after the widget tree and GoRouter are mounted.
  Future<void> handleInitialMessage() async {
    if (_initialMessageHandled || kIsWeb) return;
    _initialMessageHandled = true;

    try {
      final initialMessage = await _firebaseMessaging.getInitialMessage();
      if (initialMessage != null) {
        log('🚀 App opened from terminated state via FCM: ${initialMessage.data}');
        await _handleNotificationClick(initialMessage.data);
        return;
      }

      final launchDetails =
          await _flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
      if (launchDetails != null &&
          launchDetails.didNotificationLaunchApp &&
          launchDetails.notificationResponse?.payload != null) {
        final payload = launchDetails.notificationResponse!.payload!;
        final decoded = jsonDecode(payload);
        if (decoded is Map<String, dynamic>) {
          log('🚀 App opened from terminated state via local notification: $decoded');
          await _handleNotificationClick(decoded);
        }
      }
    } catch (e, s) {
      log('⚠️ Failed to handle initial notification message: $e');
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

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      await _firebaseMessaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  // ---------------- LOCAL NOTIFICATION ----------------
  Future<void> _initLocalNotifications() async {
    const androidInitSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const darwinInitSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidInitSettings,
      iOS: darwinInitSettings,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        if (response.payload == null || response.payload!.isEmpty) return;

        try {
          final decoded = jsonDecode(response.payload!);
          if (decoded is Map<String, dynamic>) {
            log('🟢 Notification clicked: $decoded');
            _handleNotificationClick(decoded);
          } else if (decoded is Map) {
            final data = Map<String, dynamic>.from(decoded);
            log('🟢 Notification clicked: $data');
            _handleNotificationClick(data);
          }
        } catch (e) {
          log('⚠️ Failed to decode notification payload: $e');
        }
      },
    );

    if (defaultTargetPlatform == TargetPlatform.android) {
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_highImportanceChannel);
    }
  }

  // ---------------- FIREBASE LISTENERS ----------------
  void _initFirebaseListeners() {
    FirebaseMessaging.onMessage.listen((message) {
      log('📩 Foreground message: ${message.notification?.title ?? message.data['title']}');

      if (defaultTargetPlatform == TargetPlatform.iOS) {
        // On iOS, setForegroundNotificationPresentationOptions displays messages
        // that carry a notification payload natively. Only show a local
        // notification for data-only messages to avoid duplicate banners.
        final hasDisplayData =
            message.data['title'] != null || message.data['body'] != null;
        if (message.notification == null && hasDisplayData) {
          _showNotification(message);
        }
      } else {
        _showNotification(message);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      log('🟢 Opened from notification: ${message.data}');
      _handleNotificationClick(message.data);
    });
  }

  // ---------------- TOKEN HANDLING ----------------
  void _initTokenHandling() {
    getAndSaveToken();

    // Token refresh listener
    _firebaseMessaging.onTokenRefresh.listen((newToken) async {
      log('🔄 FCM Token refreshed: $newToken');
      await _storageService.saveFcmToken(fcmToken: newToken);

      try {
        final authToken = await _storageService.getToken();
        if (authToken != null && authToken.isNotEmpty) {
          await AuthServices().sendFcmToken(fcmToken: newToken);
        }
      } catch (e) {
        log('⚠️ Failed to sync refreshed FCM token: $e');
      }
    });
  }

  /// Fetches the current FCM token (waiting briefly for APNs on iOS) and saves it.
  Future<String?> getAndSaveToken() async {
    try {
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        String? apnsToken = await _firebaseMessaging.getAPNSToken();
        for (int attempt = 0; attempt < 5 && apnsToken == null; attempt++) {
          await Future.delayed(const Duration(seconds: 1));
          apnsToken = await _firebaseMessaging.getAPNSToken();
        }
        if (apnsToken == null) {
          log('⚠️ APNs token not available yet; will rely on onTokenRefresh or later retry.');
          return null;
        }
      } else {
        await Future.delayed(const Duration(seconds: 2));
      }

      final token = await _firebaseMessaging.getToken();
      if (token != null && token.isNotEmpty) {
        log('🔥 FCM Token: $token');
        await _storageService.saveFcmToken(fcmToken: token);
        return token;
      }
    } catch (e) {
      log('⚠️ FCM token fetch failed (will retry later): $e');
    }
    return null;
  }

  // ---------------- SHOW NOTIFICATION ----------------
  Future<void> _showNotification(RemoteMessage message) async {
    final androidDetails = AndroidNotificationDetails(
      _highImportanceChannel.id,
      _highImportanceChannel.name,
      channelDescription: _highImportanceChannel.description,
      importance: Importance.max,
      priority: Priority.high,
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
    );

    final title =
        message.notification?.title ?? message.data['title']?.toString() ?? 'No Title';
    final body =
        message.notification?.body ?? message.data['body']?.toString() ?? 'No Body';
    final notificationId = message.messageId?.hashCode ?? DateTime.now().millisecondsSinceEpoch ~/ 1000;

    await _flutterLocalNotificationsPlugin.show(
      notificationId,
      title,
      body,
      notificationDetails,
      payload: jsonEncode(message.data),
    );
  }

  // ---------------- NAVIGATION ON CLICK ----------------
  Future<void> _handleNotificationClick(Map<String, dynamic> data) async {
    try {
      final authToken = await _storageService.getToken();
      if (authToken == null || authToken.isEmpty) {
        log('ℹ️ Ignoring notification navigation: user is not logged in.');
        return;
      }

      final role = await _storageService.getUserRole();
      final userType = _mapRoleToUserType(role);

      final rawTarget =
          (data['route'] ?? data['screen'] ?? data['type'])?.toString().trim();

      if (rawTarget == null || rawTarget.isEmpty) {
        if (userType != null) {
          appRouter.goNamed(RouteConstants.bottomNavScreen, extra: userType);
        }
        return;
      }

      if (rawTarget.startsWith('/')) {
        appRouter.push(rawTarget);
        return;
      }

      final resolvedRoute = _resolveNamedRoute(rawTarget, role);
      if (resolvedRoute != null) {
        if (resolvedRoute == RouteConstants.bottomNavScreen) {
          appRouter.goNamed(RouteConstants.bottomNavScreen, extra: userType);
        } else {
          appRouter.pushNamed(resolvedRoute);
        }
      } else if (userType != null) {
        appRouter.goNamed(RouteConstants.bottomNavScreen, extra: userType);
      }
    } catch (e, s) {
      log('⚠️ Notification navigation error: $e');
      log('$s');
    }
  }

  UserType? _mapRoleToUserType(String? role) {
    switch (role) {
      case 'guardian':
        return UserType.parent;
      case 'teacher':
        return UserType.teacher;
      case 'staff':
        return UserType.nonTeachingStaff;
      default:
        return null;
    }
  }

  String? _resolveNamedRoute(String target, String? role) {
    switch (target.toLowerCase()) {
      case 'notice':
      case 'notices':
      case 'noticedetaillistscreen':
        return RouteConstants.noticeListscreen;
      case 'event':
      case 'events':
      case 'eventlistscreen':
        return RouteConstants.eventListscreen;
      case 'news':
      case 'newsscreen':
        return RouteConstants.newsScreen;
      case 'chat':
      case 'chats':
      case 'message':
      case 'messages':
      case 'communication':
      case 'communicationlistingscreen':
        return RouteConstants.communicationListingScreen;
      case 'homework':
      case 'homeworks':
      case 'homeworklisitingscreen':
        return RouteConstants.homeworkLisitingScreen;
      case 'leave':
      case 'leaves':
      case 'leave_request':
        return role == 'guardian'
            ? RouteConstants.bottomNavScreen
            : RouteConstants.staffLeaveRequestHome;
      case 'student_leave':
      case 'studentleaveletter':
        return RouteConstants.studentLeaveLetter;
      case 'parent_note':
      case 'parent_notes':
      case 'parentnoteslistingscreen':
        return RouteConstants.parentNotesListingScreen;
      case 'home':
      case 'bottomnavscreen':
        return RouteConstants.bottomNavScreen;
      default:
        return target;
    }
  }
}

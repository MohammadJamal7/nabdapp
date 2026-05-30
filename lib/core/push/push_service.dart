import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import '../api/api_client.dart';
import '../constants/api_constants.dart';
import '../navigation/navigator_key.dart';

class PushService {
  static bool _initialized = false;
  static final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  static final _foregroundMessageController = StreamController<RemoteMessage>.broadcast();
  static Stream<RemoteMessage> get foregroundMessageStream => _foregroundMessageController.stream;

  static Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    final messaging = FirebaseMessaging.instance;

    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Initialize local notifications (for foreground system notifications)
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(android: androidSettings, iOS: iosSettings);
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onLocalNotificationTap,
    );

    messaging.onTokenRefresh.listen(_registerToken);

    // Foreground — show system notification + emit to stream
    FirebaseMessaging.onMessage.listen((message) {
      _showLocalNotification(message);
      _foregroundMessageController.add(message);
    });

    // Background notification tap → app opened
    FirebaseMessaging.onMessageOpenedApp.listen(_handleFcmTap);

    // Closed app notification tap → app launched
    final initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) {
      Future.microtask(() => _handleFcmTap(initialMessage));
    }
  }

  /// Call after every successful login to register FCM token on the server
  static Future<void> registerTokenAfterLogin() async {
    final messaging = FirebaseMessaging.instance;
    final fcmToken = await messaging.getToken();
    debugPrint('fcmToken: $fcmToken');
    if (fcmToken != null) {
      await _registerToken(fcmToken);
    }
  }

  static void _showLocalNotification(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    const androidDetails = AndroidNotificationDetails(
      'nabd_channel',
      'Nabd Notifications',
      channelDescription: 'Nabd app notifications',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      notification.title,
      notification.body,
      details,
    );
  }

  static void _onLocalNotificationTap(NotificationResponse response) {
    _navigateToApp();
  }

  static void _handleFcmTap(RemoteMessage message) {
    _navigateToApp();
  }

  static void _navigateToApp() {
    final context = navigatorKey.currentContext;
    if (context == null) return;
    GoRouter.of(context).go('/patient');
  }

  static Future<void> _registerToken(String token) async {
    try {
      await ApiClient.post(ApiConstants.deviceTokens, data: {'fcmToken': token});
    } catch (_) {}
  }
}

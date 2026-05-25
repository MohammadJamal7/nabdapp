import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../api/api_client.dart';
import '../constants/api_constants.dart';

class PushService {
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    await _notifications.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
      onDidReceiveNotificationResponse: (_) {},
    );

    final messaging = FirebaseMessaging.instance;

    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    final fcmToken = await messaging.getToken();
    if (fcmToken != null) {
      _registerToken(fcmToken);
    }

    messaging.onTokenRefresh.listen(_registerToken);
    FirebaseMessaging.onMessage.listen(_onMessage);

    _initialized = true;
  }

  static void _registerToken(String token) {
    ApiClient.post(ApiConstants.deviceTokens, data: {'fcmToken': token});
  }

  static Future<void> _onMessage(RemoteMessage message) async {
    final notification = message.notification;
    if (notification != null) {
      const androidDetails = AndroidNotificationDetails('nabd_alerts', 'نبض', channelDescription: 'تنبيهات التطبيق');
      await _notifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(android: androidDetails, iOS: DarwinNotificationDetails()),
      );
    }
  }
}

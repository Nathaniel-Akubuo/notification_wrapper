import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final _localNotifications = FlutterLocalNotificationsPlugin();
@pragma('vm:entry-point')
void localNotificationsBackgroundHandler(NotificationResponse details) async {}

@pragma('vm:entry-point')
Future<void> firebaseBackgroundHandler(RemoteMessage message) async {}

class HelperFunctions {
  static Future<void> setupLocalNotifications(
    ValueChanged<RemoteMessage>? onTap,
  ) async {
    await _localNotifications.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
      onDidReceiveBackgroundNotificationResponse:
          localNotificationsBackgroundHandler,
      onDidReceiveNotificationResponse: (details) {
        var map = jsonDecode(details.payload ?? '{}');
        onTap?.call(RemoteMessage.fromMap(map));
      },
    );

    var foregroundNotificationChannel = const AndroidNotificationChannel(
      'notificationChannelKey',
      'Basic Notification Channel',
      importance: Importance.max,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(foregroundNotificationChannel);
  }

  static Future<void> showNotifications(RemoteMessage message) async {
    RemoteNotification notification = message.notification!;
    AndroidNotification? android = message.notification!.android;

    if (android != null) {
      const androidDetails = AndroidNotificationDetails(
        'notificationChannelKey',
        'Basic Notification Channel',
        priority: Priority.max,
        importance: Importance.max,
      );

      const iosDetails = DarwinNotificationDetails(presentSound: true);

      _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(android: androidDetails, iOS: iosDetails),
        payload: jsonEncode(message.toMap()),
      );
    }
  }
}

import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:notification_wrapper/src/typedefs.dart';

final _localNotifications = FlutterLocalNotificationsPlugin();

@pragma('vm:entry-point')
void localNotificationsBackgroundHandler(NotificationResponse details) async {}

@pragma('vm:entry-point')
Future<void> firebaseBackgroundHandler(RemoteMessage message) async {}

const _channelKey = 'notificationChannelKey';

class HelperFunctions {
  static final _fcm = FirebaseMessaging.instance;

  static Future<void> setupLocalNotifications(
    PayloadCallback? onTap, [
    String? androidSound,
    String? channelKey,
  ]) async {
    await _requestPermission();
    await _localNotifications.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
      onDidReceiveBackgroundNotificationResponse:
          localNotificationsBackgroundHandler,
      onDidReceiveNotificationResponse: (details) {
        var map = jsonDecode(details.payload ?? '{}');
        onTap?.call(map);
      },
    );

    var foregroundNotificationChannel = AndroidNotificationChannel(
      channelKey ?? _channelKey,
      'Basic Notification Channel',
      importance: Importance.max,
      playSound: androidSound != null,
      sound: androidSound == null
          ? null
          : RawResourceAndroidNotificationSound(androidSound),
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(foregroundNotificationChannel);
  }

  static Future<void> showNotifications(
    RemoteMessage message, [
    String? androidSound,
    String? channelKey,
  ]) async {
    RemoteNotification notification = message.notification!;
    AndroidNotification? android = message.notification!.android;

    if (android != null) {
      final androidDetails = AndroidNotificationDetails(
        channelKey ?? _channelKey,
        'Basic Notification Channel',
        priority: Priority.max,
        importance: Importance.max,
        playSound: androidSound != null,
        sound: androidSound == null
            ? null
            : RawResourceAndroidNotificationSound(androidSound),
      );

      const iosDetails = DarwinNotificationDetails(presentSound: true);

      _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(android: androidDetails, iOS: iosDetails),
        payload: jsonEncode(message.data),
      );
    }
  }

  static Future<void> setIOSOptions() =>
      _fcm.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

  static Future<void> _requestPermission() async {
    if (Platform.isIOS == false) return;

    final status = (await _fcm.getNotificationSettings()).authorizationStatus;
    final granted = status == AuthorizationStatus.authorized;
    if (granted == false) {
      await _fcm.requestPermission(
        alert: true,
        announcement: true,
        badge: true,
        carPlay: true,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
    }
  }
}

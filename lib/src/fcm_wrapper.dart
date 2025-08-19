import 'package:firebase_messaging/firebase_messaging.dart';

class FCMWrapper {
  static final FCMWrapper instance = FCMWrapper._();

  FCMWrapper._();

  static final _fcm = FirebaseMessaging.instance;

  Future<void> subscribeToTopic(String topic) => _fcm.subscribeToTopic(topic);

  Future<void> unsubscribeFromTopic(String topic) =>
      _fcm.unsubscribeFromTopic(topic);

  Future<NotificationSettings> getNotificationSettings() =>
      _fcm.getNotificationSettings();

  Future<NotificationSettings> requestPermission({
    bool alert = true,
    bool announcement = false,
    bool badge = true,
    bool carPlay = false,
    bool criticalAlert = false,
    bool provisional = false,
    bool sound = true,
    bool providesAppNotificationSettings = false,
  }) =>
      _fcm.requestPermission(
        alert: alert,
        announcement: announcement,
        badge: badge,
        carPlay: carPlay,
        criticalAlert: criticalAlert,
        provisional: provisional,
        sound: sound,
        providesAppNotificationSettings: providesAppNotificationSettings,
      );

  Future<void> setForegroundNotificationPresentationOptions({
    bool alert = false,
    bool badge = false,
    bool sound = false,
  }) {
    return _fcm.setForegroundNotificationPresentationOptions(
      alert: alert,
      badge: badge,
      sound: sound,
    );
  }
}

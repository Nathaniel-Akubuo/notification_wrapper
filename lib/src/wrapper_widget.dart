import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:notification_wrapper/src/typedefs.dart';

import 'helper_functions.dart';

class NotificationWrapperWidget extends StatefulWidget {
  final Widget child;

  final RemoteMessageCallback? onNotificationReceived;
  final RemoteMessageCallback? onTap;
  final RemoteMessageCallback? showNotification;

  final TokenCallback? onTokenRefresh;
  final TokenCallback? onGetToken;

  final String? androidSoundFile;
  final String? channelKey;

  const NotificationWrapperWidget({
    super.key,
    required this.child,
    this.onNotificationReceived,
    this.onTap,
    this.showNotification,
    this.onTokenRefresh,
    this.onGetToken,
    this.androidSoundFile,
    this.channelKey,
  });

  @override
  State<NotificationWrapperWidget> createState() =>
      _NotificationWrapperWidgetState();
}

class _NotificationWrapperWidgetState extends State<NotificationWrapperWidget> {
  final _fcm = FirebaseMessaging.instance;

  @override
  void initState() {
    super.initState();

    _listenForNotifications();
  }

  Future<void> _listenForNotifications() async {
    await HelperFunctions.setupLocalNotifications(
      widget.onTap,
      widget.androidSoundFile,
      widget.channelKey,
    );
    await HelperFunctions.setIOSOptions();
    var token = await _fcm.getToken();
    widget.onGetToken?.call(token);

    RemoteMessage? initialMessage = await _fcm.getInitialMessage();

    if (initialMessage != null) {
      widget.onNotificationReceived?.call(initialMessage);
    }

    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      widget.onNotificationReceived?.call(event);
    });

    FirebaseMessaging.onMessage.listen((event) {
      widget.onNotificationReceived?.call(event);
      if (widget.showNotification != null) {
        widget.showNotification!(event);
      } else {
        HelperFunctions.showNotifications(
          event,
          widget.androidSoundFile,
          widget.channelKey,
        );
      }
    });

    _fcm.onTokenRefresh.listen(widget.onTokenRefresh);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';

import 'helper_functions.dart';

class WrapperWidget extends StatefulWidget {
  final Widget child;

  final ValueChanged<RemoteMessage>? onNotificationReceived;
  final ValueChanged<RemoteMessage>? onTap;
  final ValueChanged<RemoteMessage>? showNotification;

  final ValueChanged<String>? onTokenRefresh;

  const WrapperWidget({
    super.key,
    required this.child,
    this.onNotificationReceived,
    this.onTap,
    this.showNotification,
    this.onTokenRefresh,
  });

  @override
  State<WrapperWidget> createState() => _WrapperWidgetState();
}

class _WrapperWidgetState extends State<WrapperWidget> {
  final _fcm = FirebaseMessaging.instance;

  @override
  void initState() {
    super.initState();

    _listenForNotifications();
  }

  Future<void> _listenForNotifications() async {
    await HelperFunctions.setupLocalNotifications(widget.onTap);

    RemoteMessage? initialMessage = await _fcm.getInitialMessage();

    if (initialMessage != null) {
      widget.onNotificationReceived?.call(initialMessage);
    }

    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      widget.onNotificationReceived?.call(event);
    });

    FirebaseMessaging.onMessage.listen((event) {
      if (widget.showNotification != null) {
        widget.showNotification!(event);
      } else {
        HelperFunctions.showNotifications(event);
      }
    });

    _fcm.onTokenRefresh.listen((event) => widget.onTokenRefresh?.call(event));
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

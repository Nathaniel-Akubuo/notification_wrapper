import 'package:flutter/widgets.dart';
import 'package:jpush_flutter/jpush_flutter.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:jpush_flutter/jpush_interface.dart';

import 'helper_functions.dart';
import 'typedefs.dart';

class NotificationWrapperWidget extends StatefulWidget {
  final Widget child;

  final RemoteMessageCallback? onNotificationReceived;
  final PayloadCallback? onTap;
  final RemoteMessageCallback? showNotification;
  final RemoteMessageCallback? backgroundHandler;
  final bool Function(RemoteMessage)? shouldShowNotification;

  final TokenCallback? onTokenRefresh;
  final TokenCallback? onGetToken;

  final String? androidSoundFile;
  final String? channelKey;
  final String? jpushAppKey;

  const NotificationWrapperWidget({
    super.key,
    required this.child,
    this.onNotificationReceived,
    this.onTap,
    this.showNotification,
    this.backgroundHandler,
    this.shouldShowNotification,
    this.onTokenRefresh,
    this.onGetToken,
    this.androidSoundFile,
    this.channelKey,
    this.jpushAppKey,
  });

  @override
  State<NotificationWrapperWidget> createState() =>
      _NotificationWrapperWidgetState();
}

class _NotificationWrapperWidgetState extends State<NotificationWrapperWidget> {
  final _fcm = FirebaseMessaging.instance;
  final _jPush = JPush.newJPush();

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await HelperFunctions.setupLocalNotifications(
      widget.onTap,
      widget.androidSoundFile,
      widget.channelKey,
    );
    if (widget.jpushAppKey != null) await _initJPush();

    await _initFCM();
  }

  Future<void> _initFCM() async {
    await HelperFunctions.setIOSOptions();

    final token = await _fcm.getToken();
    widget.onGetToken?.call(token);

    final initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      widget.onNotificationReceived?.call(initialMessage);
    }

    FirebaseMessaging.onMessageOpenedApp.listen((msg) {
      widget.onNotificationReceived?.call(msg);
      widget.onTap?.call(msg.data);
    });

    FirebaseMessaging.onMessage.listen((msg) {
      widget.onNotificationReceived?.call(msg);

      _checkAndShowNotification(msg);
    });

    if (widget.backgroundHandler != null) {
      FirebaseMessaging.onBackgroundMessage(widget.backgroundHandler!);
    }

    _fcm.onTokenRefresh.listen(widget.onTokenRefresh);
  }

  Future<void> _initJPush() async {
    _jPush.setup(
      appKey: widget.jpushAppKey ?? '',
      channel: widget.channelKey ?? "default",
    );

    _jPush.applyPushAuthority(
      const NotificationSettingsIOS(
        sound: true,
        alert: true,
        badge: true,
      ),
    );

    final rid = await _jPush.getRegistrationID();
    widget.onGetToken?.call(rid);

    _jPush.addEventHandler(
      onReceiveNotification: (msg) async {
        final converted = _convertToRemoteMessage(msg);
        widget.onNotificationReceived?.call(converted);
        _checkAndShowNotification(converted);
      },
      onOpenNotification: (msg) async {
        final converted = _convertToRemoteMessage(msg);
        widget.onNotificationReceived?.call(converted);
        widget.onTap?.call(converted.data);
      },
      onReceiveMessage: (msg) async {
        final converted = _convertToRemoteMessage(msg);
        widget.onNotificationReceived?.call(converted);
      },
    );
  }

  RemoteMessage _convertToRemoteMessage(Map<String, dynamic> msg) {
    return RemoteMessage(
      data: Map<String, dynamic>.from(msg["extras"] ?? {}),
      notification: RemoteNotification(
        title: msg["title"]?.toString(),
        body: msg["alert"]?.toString(),
      ),
    );
  }

  void _checkAndShowNotification(RemoteMessage message) {
    final shouldShow = widget.shouldShowNotification?.call(message) ?? true;

    if (shouldShow) {
      if (widget.showNotification != null) {
        widget.showNotification!(message);
      } else {
        HelperFunctions.showNotifications(
          message,
          widget.androidSoundFile,
          widget.channelKey,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

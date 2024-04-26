import 'package:firebase_messaging/firebase_messaging.dart';

typedef RemoteMessageCallback = Future<void> Function(RemoteMessage);

typedef TokenCallback = void Function(String?);

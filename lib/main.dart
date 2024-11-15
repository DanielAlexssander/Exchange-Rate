import 'package:exchange_rate/Controllers/notificationController.dart';
import 'package:flutter/material.dart';

import 'package:exchange_rate/myApp.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  NotificationController.initialize(flutterLocalNotificationsPlugin);

  runApp(MyApp());
}

import 'package:exchange_rate/Controllers/convertController.dart';
import 'package:exchange_rate/Controllers/settingsController.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'dart:io' show Platform;

class NotificationController extends ChangeNotifier {
  static NotificationController instance = NotificationController();

  ValueNotifier<String> criptoCurrency_1 = ValueNotifier("BTC");
  ValueNotifier<String> criptoCurrency_2 = ValueNotifier("USDC");

  ValueNotifier<String> defaultCurrency_1 = ValueNotifier("BRL");
  ValueNotifier<String> defaultCurrency_2 = ValueNotifier("BRL");

  ValueNotifier<String> hoursNotification = ValueNotifier("24");

  static Future initialize(
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
    const initializationSettingsAndroid =
        AndroidInitializationSettings('mipmap/launcher_icon');

    const initializationSettingsDarwin = DarwinInitializationSettings(
        requestSoundPermission: true,
        requestBadgePermission: true,
        requestAlertPermission: true);

    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    if (Platform.isIOS) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    } else if (Platform.isAndroid) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // Agendamento
  static Future<void> notificationPrices(
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
    const androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'repeating_channel_id',
      'repeating_channel_name',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );

    const iosPlatformChannelSpecifics = DarwinNotificationDetails();

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iosPlatformChannelSpecifics,
    );

    String notifyCriptoSetted_1 =
        NotificationController.instance.criptoCurrency_1.value;
    String notifyCriptoSetted_2 =
        NotificationController.instance.criptoCurrency_2.value;
    String notifyCurrencySetted_1 =
        NotificationController.instance.defaultCurrency_1.value;
    String notifyCurrencySetted_2 =
        NotificationController.instance.defaultCurrency_2.value;

    // Get configurantion by data cache
    if (await SettingsController.instance
            .getDataFromCache("criptoCurrency_1", "string") !=
        null) {
      notifyCriptoSetted_1 = await SettingsController.instance
          .getDataFromCache("criptoCurrency_1", "string");
    }
    if (await SettingsController.instance
            .getDataFromCache("criptoCurrency_2", "string") !=
        null) {
      notifyCriptoSetted_2 = await SettingsController.instance
          .getDataFromCache("criptoCurrency_2", "string");
    }
    if (await SettingsController.instance
            .getDataFromCache("defaultCurrency_1", "string") !=
        null) {
      notifyCurrencySetted_1 = await SettingsController.instance
          .getDataFromCache("defaultCurrency_1", "string");
    }
    if (await SettingsController.instance
            .getDataFromCache("defaultCurrency_2", "string") !=
        null) {
      notifyCurrencySetted_2 = await SettingsController.instance
          .getDataFromCache("defaultCurrency_2", "string");
    }

    var result_1 = "";
    var result_2 = "";

    if (result_1 == "") {
      result_1 = await ConvertController.instance.convertCurrency(
        notifyCriptoSetted_1,
        notifyCurrencySetted_1,
      );
    }
    if (result_2 == "") {
      result_2 = await ConvertController.instance.convertCurrency(
        notifyCriptoSetted_2,
        notifyCurrencySetted_2,
      );
    }

    await flutterLocalNotificationsPlugin.show(
      0,
      'Currency Costing',
      result_1 == "null" || result_2 == "null"
          ? "There was a problem with the connection. Please check your connection."
          : "1 ${notifyCriptoSetted_1} = ${notifyCurrencySetted_1} $result_1\n1 ${notifyCriptoSetted_2} = ${notifyCurrencySetted_2} $result_2",
      platformChannelSpecifics,
    );
  }

  setCriptoCurrency([String value = "", String value2 = ""]) {
    if (value != '') {
      criptoCurrency_1.value = value;
      SettingsController.instance.saveDataToCache(
          "criptoCurrency_1", criptoCurrency_1.value, "string");
    } else if (value2 != '') {
      criptoCurrency_2.value = value2;
      SettingsController.instance.saveDataToCache(
          "criptoCurrency_2", criptoCurrency_2.value, "string");
    }

    notifyListeners();
  }

  setDefaultCurrency([String value = "", String value2 = ""]) {
    if (value != '') {
      defaultCurrency_1.value = value;
      SettingsController.instance.saveDataToCache(
          "defaultCurrency_1", defaultCurrency_1.value, "string");
    } else if (value2 != '') {
      defaultCurrency_2.value = value2;
      SettingsController.instance.saveDataToCache(
          "defaultCurrency_2", defaultCurrency_2.value, "string");
    }

    notifyListeners();
  }

  setHoursToNotification(value) {
    hoursNotification.value = value;

    SettingsController.instance.saveDataToCache(
        "hoursNotification", hoursNotification.value, "string");

    notifyListeners();
  }
}

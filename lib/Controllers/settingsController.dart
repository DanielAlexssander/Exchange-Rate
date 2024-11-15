import 'package:shared_preferences/shared_preferences.dart';
import 'package:exchange_rate/Controllers/brightnessController.dart';
import 'package:exchange_rate/Controllers/notificationController.dart';
import 'package:exchange_rate/Controllers/currenciesController.dart';

class SettingsController {
  static SettingsController instance = SettingsController();

  setSettings() async {
    if (await getDataFromCache("brightness", "bool") != null) {
      BrightnessController.instance.brightness.value =
          await getDataFromCache("brightness", "bool");
    }
    if (await getDataFromCache("defaultCurrency", "string") != null) {
      Currenciescontroller.instance.defaultCurrency.value =
          await getDataFromCache("defaultCurrency", "string");
    }
    // Notification Settings
    if (await getDataFromCache("criptoCurrency_1", "string") != null) {
      NotificationController.instance.criptoCurrency_1.value =
          await getDataFromCache("criptoCurrency_1", "string");
    }
    if (await getDataFromCache("criptoCurrency_2", "string") != null) {
      NotificationController.instance.criptoCurrency_2.value =
          await getDataFromCache("criptoCurrency_2", "string");
    }
    if (await getDataFromCache("defaultCurrency_1", "string") != null) {
      NotificationController.instance.defaultCurrency_1.value =
          await getDataFromCache("defaultCurrency_1", "string");
      ;
    }
    if (await getDataFromCache("defaultCurrency_2", "string") != null) {
      NotificationController.instance.defaultCurrency_2.value =
          await getDataFromCache("defaultCurrency_2", "string");
    }
    if (await getDataFromCache("hoursNotification", "string") != null) {
      NotificationController.instance.hoursNotification.value =
          await getDataFromCache("hoursNotification", "string");
    }
  }

  saveDataToCache(key, value, type) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (type == "string") {
      await prefs.setString(key, value);
    } else if (type == "bool") {
      await prefs.setBool(key, value);
    }
  }

  getDataFromCache(key, type) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (type == "string") {
      return prefs.getString(key);
    } else if (type == "bool") {
      return prefs.getBool(key);
    }
  }
}

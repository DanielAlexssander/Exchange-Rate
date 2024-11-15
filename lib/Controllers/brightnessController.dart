import 'package:exchange_rate/Controllers/settingsController.dart';
import 'package:flutter/material.dart';

class BrightnessController extends ChangeNotifier {
  static BrightnessController instance = BrightnessController();

  ValueNotifier<bool> brightness = ValueNotifier(false);

  changeTheme() {
    brightness.value = !brightness.value;

    SettingsController.instance
        .saveDataToCache("brightness", brightness.value, "bool");

    notifyListeners();
  }
}

import 'package:exchange_rate/Controllers/settingsController.dart';
import 'package:flutter/material.dart';

class Currenciescontroller extends ChangeNotifier {
  static Currenciescontroller instance = Currenciescontroller();

  ValueNotifier<String> defaultCurrency = ValueNotifier("BRL");

  setCurrency(value) {
    defaultCurrency.value = value;

    SettingsController.instance
        .saveDataToCache("defaultCurrency", defaultCurrency.value, "string");

    notifyListeners();
  }
}

import 'package:exchange_rate/Controllers/brightnessController.dart';
import 'package:exchange_rate/Controllers/settingsController.dart';
import 'package:exchange_rate/Pages/principalPage.dart';

import 'package:flutter/material.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<dynamic> loadData() async {
    await SettingsController.instance.setSettings();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: loadData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: CircularProgressIndicator(
              color: Colors.amber,
            ));
          } else {
            return AnimatedBuilder(
              animation: BrightnessController.instance,
              builder: (context, child) {
                return MaterialApp(
                  title: "Exchange Rate",
                  theme: ThemeData(
                    colorScheme: ColorScheme.fromSwatch(
                        primarySwatch: Colors.amber,
                        accentColor: Colors.yellow,
                        brightness:
                            BrightnessController.instance.brightness.value
                                ? Brightness.dark
                                : Brightness.light),
                  ),
                  initialRoute: '/',
                  routes: {'/': (context) => PrincipalPage()},
                );
              },
            );
          }
        });
  }
}

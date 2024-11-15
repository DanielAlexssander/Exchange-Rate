// Flutter
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Controllers
import 'package:exchange_rate/Controllers/brightnessController.dart';
import 'package:exchange_rate/Controllers/convertController.dart';
import 'package:exchange_rate/Controllers/currenciesController.dart';
import 'package:exchange_rate/Controllers/notificationController.dart';
import 'package:workmanager/workmanager.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

List<String> currencies = <String>['BRL', 'USD', 'EUR'];
List<String> criptos = <String>['BTC', 'USDC', 'ETH', 'EURI'];

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      await NotificationController.notificationPrices(
          flutterLocalNotificationsPlugin);
    } catch (e) {
      print(e);
    }
    return Future.value(true);
  });
}

void registerWorkmanagerTask() {
  Workmanager().registerPeriodicTask(
    "hour-notification-task",
    "showNotificationTask",
    frequency: Duration(
        hours:
            int.parse(NotificationController.instance.hoursNotification.value)),
  );
}

class PrincipalPage extends StatefulWidget {
  const PrincipalPage({super.key});

  @override
  State<PrincipalPage> createState() => _PrincipalPageState();
}

class _PrincipalPageState extends State<PrincipalPage> {
  int _currentIndex = 0;
  List<Widget> body = const [Home(), Settings()];

  @override
  void initState() {
    super.initState();

    Workmanager().initialize(callbackDispatcher, isInDebugMode: false);

    registerWorkmanagerTask();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: BottomNavigationBar(
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
          currentIndex: _currentIndex,
          onTap: (int newIndex) {
            setState(() {
              _currentIndex = newIndex;
            });
          },
        ),
        appBar: AppBar(
            backgroundColor: Colors.black,
            title: Row(
              children: [
                Container(
                  width: 40,
                  child: Image.asset("assets/images/coin.png"),
                ),
                Container(
                  width: 10,
                ),
                Text(
                  "Exchange Rate",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            )),
        body: body[_currentIndex]);
  }
}

// Bodys
class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Center(
          child: CarouselSlider(
              options: CarouselOptions(
                  height: 400.0,
                  autoPlay: true,
                  autoPlayInterval: Duration(seconds: 5)),
              items: [
            CurrencyItemless(
              currency: "BTC",
              assetCurrency: "assets/images/bitcoin.png",
            ),
            CurrencyItemless(
              currency: "ETH",
              assetCurrency: "assets/images/eth.png",
            ),
            CurrencyItemless(
              currency: "USDC",
              assetCurrency: "assets/images/usdc.png",
            ),
            CurrencyItemless(
              currency: "EURI",
              assetCurrency: "assets/images/eur.png",
            ),
          ])),
    );
  }
}

List<String> hoursNotification = <String>[
  '1',
  '3',
  '6',
  '12',
  '18',
  '24',
  '48'
];

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: ListView(
        children: [
          Container(height: 20),
          Text(
            "Settings",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          ListTile(
            leading: Icon(Icons.currency_exchange),
            title: Text("Default Currency"),
            trailing: CurrenciesSetted(),
          ),
          Container(height: 10),
          ValueListenableBuilder(
              valueListenable: BrightnessController.instance.brightness,
              builder: (context, value, child) {
                return ListTile(
                    leading: BrightnessController.instance.brightness.value
                        ? Icon(Icons.dark_mode)
                        : Icon(Icons.sunny),
                    title: Text("Light/Dark Mode"),
                    trailing: Switch(
                        value: BrightnessController.instance.brightness.value,
                        onChanged: (value) {
                          BrightnessController.instance.changeTheme();
                        }));
              }),
          Container(height: 10),
          CurrencyNotify(),
          ListTile(
            leading: Icon(Icons.notifications_active),
            title: Text("Notification interval in hours"),
            trailing: ValueListenableBuilder(
                valueListenable:
                    NotificationController.instance.hoursNotification,
                builder: (context, value, child) {
                  return DropdownButton(
                    value:
                        NotificationController.instance.hoursNotification.value,
                    items: hoursNotification
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? value) async {
                      await NotificationController.instance
                          .setHoursToNotification(value);

                      Workmanager()
                          .cancelByUniqueName("hour-notification-task");

                      registerWorkmanagerTask();
                    },
                  );
                }),
          ),
          Container(height: 10),
          ListTile(
            leading: Icon(Icons.notification_add),
            title: Text("Test Notification"),
            trailing: ElevatedButton(
                onPressed: () {
                  NotificationController.notificationPrices(
                      flutterLocalNotificationsPlugin);
                },
                child: Text("Click")),
          ),
        ],
      ),
    );
  }
}

// Components
// ignore: must_be_immutable
class CurrencyItemless extends StatelessWidget {
  final String currency;
  final String assetCurrency;
  CurrencyItemless(
      {super.key, required this.currency, required this.assetCurrency});

  ValueNotifier<String> result = ValueNotifier("");

  Future<dynamic> _initializeResult() async {
    if (result.value == "") {
      result.value = await ConvertController.instance.convertCurrency(
        currency,
        Currenciescontroller.instance.defaultCurrency.value,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    _initializeResult();

    return Card(
      color: BrightnessController.instance.brightness.value
          ? Colors.black.withOpacity(0.35)
          : Colors.grey[300],
      child: Container(
        width: MediaQuery.of(context).size.width - 120,
        margin: EdgeInsets.symmetric(horizontal: 5.0),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 200, child: Image.asset(assetCurrency)),
              Container(height: 50),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text(currency),
                      Text(
                        "1",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                  Column(
                    children: [
                      Text(Currenciescontroller.instance.defaultCurrency.value),
                      ValueListenableBuilder(
                          valueListenable: result,
                          builder: (context, value, child) {
                            return Text(result.value,
                                style: TextStyle(fontWeight: FontWeight.bold));
                          })
                    ],
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class CurrenciesSetted extends StatefulWidget {
  const CurrenciesSetted({super.key});

  @override
  State<CurrenciesSetted> createState() => _CurrenciesSettedState();
}

class _CurrenciesSettedState extends State<CurrenciesSetted> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: Currenciescontroller.instance.defaultCurrency,
        builder: (context, value, child) {
          return DropdownButton(
            value: Currenciescontroller.instance.defaultCurrency.value,
            items: currencies.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? value) {
              Currenciescontroller.instance.setCurrency(value);
            },
          );
        });
  }
}

class CurrencyNotify extends StatefulWidget {
  const CurrencyNotify({super.key});

  @override
  State<CurrencyNotify> createState() => _CurrencyNotifyState();
}

class _CurrencyNotifyState extends State<CurrencyNotify> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Icon(Icons.edit_notifications),
          title: Text("Currency Costing Notification"),
          trailing: Icon(Icons.arrow_downward),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20.0, 0, 20.0, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ValueListenableBuilder(
                  valueListenable:
                      NotificationController.instance.criptoCurrency_1,
                  builder: (context, value, child) {
                    return DropdownButton(
                      value: NotificationController
                          .instance.criptoCurrency_1.value,
                      items:
                          criptos.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        NotificationController.instance
                            .setCriptoCurrency(value!);
                      },
                    );
                  }),
              Text("TO"),
              ValueListenableBuilder(
                  valueListenable:
                      NotificationController.instance.defaultCurrency_1,
                  builder: (context, value, child) {
                    return DropdownButton(
                      value: NotificationController
                          .instance.defaultCurrency_1.value,
                      items: currencies
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        NotificationController.instance
                            .setDefaultCurrency(value!);
                      },
                    );
                  }),
            ],
          ),
        ),
        // another
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ValueListenableBuilder(
                  valueListenable:
                      NotificationController.instance.criptoCurrency_2,
                  builder: (context, value, child) {
                    return DropdownButton(
                      value: NotificationController
                          .instance.criptoCurrency_2.value,
                      items:
                          criptos.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        NotificationController.instance
                            .setCriptoCurrency("", value!);
                      },
                    );
                  }),
              Text("TO"),
              ValueListenableBuilder(
                  valueListenable:
                      NotificationController.instance.defaultCurrency_2,
                  builder: (context, value, child) {
                    return DropdownButton(
                      value: NotificationController
                          .instance.defaultCurrency_2.value,
                      items: currencies
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        NotificationController.instance
                            .setDefaultCurrency("", value!);
                      },
                    );
                  }),
            ],
          ),
        )
      ],
    );
  }
}

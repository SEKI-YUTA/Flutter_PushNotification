import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized;
  runApp(const MyApp());
}

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  // handle action
}

void onDidReceiveLocalNotification(
    int id, String? title, String? body, String? payload) async {
  print("body: $body title: $title payload: $payload");
  // display a dialog with the notification details, tap ok to go to another page
  // showDialog(
  //   context: context,
  //   builder: (BuildContext context) => CupertinoAlertDialog(
  //     title: Text(title),
  //     content: Text(body),
  //     actions: [
  //       CupertinoDialogAction(
  //         isDefaultAction: true,
  //         child: Text('Ok'),
  //         onPressed: () async {
  //           Navigator.of(context, rootNavigator: true).pop();
  //           await Navigator.push(
  //             context,
  //             MaterialPageRoute(
  //               builder: (context) => SecondScreen(payload),
  //             ),
  //           );
  //         },
  //       )
  //     ],
  //   ),
  // );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  bool? _notificationGranted = false;
  // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
  final AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  final DarwinInitializationSettings initializationSettingsDarwin =
      DarwinInitializationSettings(
          requestSoundPermission: false,
          requestBadgePermission: false,
          requestAlertPermission: false,
          onDidReceiveLocalNotification: onDidReceiveLocalNotification);
  final LinuxInitializationSettings initializationSettingsLinux =
      LinuxInitializationSettings(defaultActionName: 'Open notification');
  InitializationSettings? initializationSettings;
  FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsDarwin,
        linux: initializationSettingsLinux);
    setUP();
  }

  void setUP() async {
    await flutterLocalNotificationsPlugin?.initialize(initializationSettings!,
        onDidReceiveNotificationResponse:
            (NotificationResponse notificationResponse) async {},
        onDidReceiveBackgroundNotificationResponse: notificationTapBackground);
    if (Platform.isAndroid) {
      _notificationGranted = await flutterLocalNotificationsPlugin!
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestPermission();
    } else if (Platform.isIOS) {
      _notificationGranted = await flutterLocalNotificationsPlugin!
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    }
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  Future<void> _showNotificationWithActions() async {
    // const AndroidNotificationDetails androidNotificationDetails =
    //     AndroidNotificationDetails(
    //   'channel_id',
    //   'demo_channel',
    //   channelDescription: "this is demo channel",
    //   actions: <AndroidNotificationAction>[
    //     AndroidNotificationAction('id_1', 'Action 1'),
    //     AndroidNotificationAction('id_2', 'Action 2'),
    //     AndroidNotificationAction('id_3', 'Action 3'),
    //   ],
    // );
    // const DarwinNotificationDetails darwinNotificationDetails =
    //     DarwinNotificationDetails(subtitle: "Hello!");
    // const NotificationDetails notificationDetails = NotificationDetails(
    //     android: androidNotificationDetails, iOS: darwinNotificationDetails);
    // await flutterLocalNotificationsPlugin!
    //     .show(0, '...', '...', notificationDetails);
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails('your channel id', 'your channel name',
            channelDescription: 'your channel description',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker');
    const DarwinNotificationDetails darwinNotificationDetails =
        DarwinNotificationDetails(subtitle: "this is subtitle");
    const NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails, iOS: darwinNotificationDetails);
    await flutterLocalNotificationsPlugin!.show(
        0, 'plain title', 'plain body', notificationDetails,
        payload: 'item x');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              child: Text("push notify"),
              onPressed: () {
                print("push notify");
                _showNotificationWithActions();
              },
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showNotificationWithActions();
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

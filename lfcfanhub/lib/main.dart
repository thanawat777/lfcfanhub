import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:lfcfanhub/app/controller/bottoncontrol.dart';
import 'package:lfcfanhub/app/view/favorite.dart';
import 'package:lfcfanhub/app/view/fixture.dart';
import 'package:lfcfanhub/app/view/home.dart';
import 'package:lfcfanhub/app/view/login.dart';
import 'package:lfcfanhub/app/view/news.dart';
import 'package:lfcfanhub/app/view/player.dart';
import 'package:lfcfanhub/app/view/profile.dart';

// --- Imports สำหรับ Notifications (Android เท่านั้น) ---
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

import 'package:lfcfanhub/service/storage.dart';

// *** ตัวแปร GLOBAL สำหรับ Notifications ***
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
Future<void> requestNotificationPermission() async {
  final status = await Permission.notification.status;

  final bool granted =
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.areNotificationsEnabled() ??
      false;

  if (!status.isGranted || !granted) {
    await Permission.notification.request();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await GetStorage.init();
  await requestNotificationPermission();
  tz.initializeTimeZones();
  try {
    final currentTimeZone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(currentTimeZone));
  } catch (e) {
    tz.setLocalLocation(tz.getLocation('Asia/Bangkok'));
  }

  // ตั้งค่าเริ่มต้นสำหรับ Android เท่านั้น
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/launcher_icon');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  // await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  try {
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  } catch (e) {
    print('❌ Notification init error: $e');
  }
  // ✅ สร้างช่องสำหรับ test_channel_id ล่วงหน้า
  const AndroidNotificationChannel testChannel = AndroidNotificationChannel(
    'test_channel_id', // ต้องตรงกับที่ใช้ใน zonedSchedule
    'Test Channel',
    description: 'สำหรับทดสอบการแจ้งเตือน',
    importance: Importance.high,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.createNotificationChannel(testChannel);

  // ✅ เช่นเดียวกัน หากคุณใช้ match_channel_id ต้องประกาศมันด้วยเช่นกัน

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Autwrap(),
      getPages: [
        GetPage(name: "/", page: () => Home()),
        GetPage(name: "/login", page: () => Login()),
        GetPage(name: '/news', page: () => NewsPage()),
        GetPage(name: '/player', page: () => Players()),
        GetPage(name: '/profile', page: () => Profile()),
        GetPage(name: '/fixture', page: () => FixturePage()),
        GetPage(name: '/favorite', page: () => FavoritePage()),
        GetPage(name: '/main', page: () => MainPage()),
      ],
    );
  }
}

class Autwrap extends StatelessWidget {
  const Autwrap({super.key});

  @override
  Widget build(BuildContext context) {
    if (UserStorage().isLogin()) {
      return MainPage();
    } else {
      return Login();
    }
  }
}

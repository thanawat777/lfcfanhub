import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:intl/intl.dart';
import 'package:lfcfanhub/app/model/fixtureModel.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // เก็บ id รายการโปรดไว้ในหน้านี้
  Set<String> favoriteIds = {};

  @override
  void initState() {
    super.initState();
    _initTimezone();
    _initNotification();
    fetchFavoriteIds();
    requestNotificationPermission();
  }

  Future<void> _initTimezone() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Bangkok'));
  }

  Future<void> _initNotification() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
    );

    await flutterLocalNotificationsPlugin.initialize(initSettings);
  }

  Future<void> fetchFavoriteIds() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('favorites')
          .doc(uid)
          .collection('match')
          .get();

      setState(() {
        favoriteIds = snapshot.docs.map((doc) => doc.id).toSet();
      });
    } catch (e) {
      print('Error fetching favorite IDs: $e');
    }
  }

  Future<List<FixtureModel>> fetchFavoritesFromFirebase() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return [];

    final snapshot = await FirebaseFirestore.instance
        .collection('favorites')
        .doc(uid)
        .collection('match')
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return FixtureModel(
        id: int.tryParse(data['fixtureId'].toString()) ?? 0,
        title: data['title'] ?? '',
        homeTeam: data['homeTeam'] ?? '',
        awayTeam: data['awayTeam'] ?? '',
        date: DateTime.parse(data['date']),
        stadium: data['stadium'] ?? '',
        homeTeamLogo: data['homeTeamLogo'] ?? '',
        awayTeamLogo: data['awayTeamLogo'] ?? '',
        premier: data['premier'] ?? '',
        favorite: true,
      );
    }).toList();
  }

  Future<void> removeFavorite(String fixtureId) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    await FirebaseFirestore.instance
        .collection('favorites')
        .doc(uid)
        .collection('match')
        .doc(fixtureId)
        .delete();

    await cancelNotification(int.tryParse(fixtureId) ?? 0);

    setState(() {
      favoriteIds.remove(fixtureId);
    });
  }

  Future<void> addFavorite(FixtureModel fixture) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    await FirebaseFirestore.instance
        .collection('favorites')
        .doc(uid)
        .collection('match')
        .doc(fixture.id.toString())
        .set({
          'fixtureId': fixture.id,
          'title': fixture.title,
          'homeTeam': fixture.homeTeam,
          'awayTeam': fixture.awayTeam,
          'date': fixture.date.toIso8601String(),
          'stadium': fixture.stadium,
          'homeTeamLogo': fixture.homeTeamLogo,
          'awayTeamLogo': fixture.awayTeamLogo,
          'premier': fixture.premier,
        });

    setState(() {
      favoriteIds.add(fixture.id.toString());
    });
  }

  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  Future<void> requestNotificationPermission() async {
    final status = await Permission.notification.status;
    if (!status.isGranted) {
      await Permission.notification.request();
    }
  }

  Future<void> scheduleNotification(FixtureModel fixture) async {
    final scheduledTime = tz.TZDateTime.from(
      fixture.date,
      tz.local,
    ).subtract(const Duration(minutes: 10));

    if (scheduledTime.isBefore(tz.TZDateTime.now(tz.local))) return;

    const androidDetails = AndroidNotificationDetails(
      'match_channel_id',
      'Match Notifications',
      channelDescription: 'แจ้งเตือนก่อนการแข่งขัน',
      importance: Importance.max,
      priority: Priority.high,
      sound: RawResourceAndroidNotificationSound('alert1'),
    );

    const platformDetails = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      fixture.id,
      'ใกล้ถึงเวลาแข่งแล้ว!',
      'แมตช์ ${fixture.homeTeam} vs ${fixture.awayTeam} เริ่มในอีก 10 นาที',
      scheduledTime,
      platformDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  // Future<void> testNotification() async {
  //   const androidDetails = AndroidNotificationDetails(
  //     'test_channel_id',
  //     'Test Channel',
  //     channelDescription: 'สำหรับทดสอบการแจ้งเตือน',
  //     importance: Importance.max,
  //     priority: Priority.high,
  //     sound: RawResourceAndroidNotificationSound('alert1'),
  //   );

  //   const notificationDetails = NotificationDetails(android: androidDetails);

  //   await flutterLocalNotificationsPlugin.zonedSchedule(
  //     999,
  //     'แมตซ์จะเริ่มในอีก 10 นาที',
  //     'ลิเวอร์พูล vs แมนเชสเตอร์ ยูไนเต็ด',
  //     tz.TZDateTime.now(tz.local).add(const Duration(seconds: 10)),
  //     notificationDetails,
  //     androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Favorite Matches",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.red,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<List<FixtureModel>>(
        future: fetchFavoritesFromFirebase(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());

          final matches = snapshot.data!;
          if (matches.isEmpty)
            return const Center(child: Text("ยังไม่มีแมตช์ที่ติดดาว"));

          return ListView.builder(
            itemCount: matches.length,
            itemBuilder: (context, index) {
              final fixture = matches[index];
              final date = DateFormat(
                'd MMMM y',
              ).format(fixture.date.toLocal());
              final time = DateFormat('HH:mm').format(fixture.date.toLocal());
              final isStarred = favoriteIds.contains(fixture.id.toString());

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                if (fixture.homeTeamLogo.isNotEmpty)
                                  Image.network(
                                    fixture.homeTeamLogo,
                                    height: 40,
                                  ),
                                const SizedBox(height: 5),
                                Text(
                                  fixture.homeTeam,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  "${fixture.premier}\n$date",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  time,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                Text(
                                  'Stadium: ${fixture.stadium}',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                if (fixture.awayTeamLogo.isNotEmpty)
                                  Image.network(
                                    fixture.awayTeamLogo,
                                    height: 40,
                                  ),
                                const SizedBox(height: 5),
                                Text(
                                  fixture.awayTeam,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              isStarred ? Icons.star : Icons.star_border,
                              color: isStarred
                                  ? Colors.yellow[800]
                                  : Colors.grey,
                            ),
                            onPressed: () async {
                              final id = fixture.id.toString();
                              setState(() {
                                if (isStarred) {
                                  favoriteIds.remove(id);
                                } else {
                                  favoriteIds.add(id);
                                }
                              });
                              if (isStarred) {
                                await removeFavorite(id);
                              } else {
                                await addFavorite(fixture);
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      // floatingActionButton: FloatingActionButton.extended(
      //   icon: const Icon(Icons.notifications),
      //   label: const Text('ทดสอบแจ้งเตือน'),
      //   onPressed: () async {
      //     await testNotification();
      //   },
      // ),
    );
  }
}

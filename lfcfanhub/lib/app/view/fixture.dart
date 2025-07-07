import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';
import 'package:lfcfanhub/app/view/favorite.dart';
import 'package:lfcfanhub/app/model/fixtureModel.dart';
import 'package:url_launcher/url_launcher.dart';

class FixturePage extends StatefulWidget {
  const FixturePage({super.key});

  @override
  State<FixturePage> createState() => _FixturePageState();
}

class _FixturePageState extends State<FixturePage> {
  final Dio dio = Dio();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  Set<int> starredMatches = {};
  Set<String> favoriteIds = {};

  Future<List<FixtureModel>>? futureFixtures;

  @override
  void initState() {
    super.initState();

    fetchFavoriteIds().then((_) {
      setState(() {
        futureFixtures = fetchLfcFixture();
      });
    });

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    flutterLocalNotificationsPlugin.initialize(settings);
  }

  Future<List<FixtureModel>> fetchLfcFixture() async {
    try {
      final response = await dio.get(
        'https://backend.liverpoolfc.com/lfc-rest-api/fixtures?sort=desc&teamSlug=mens&seasonYear=2025',
      );

      if (response.statusCode == 200) {
        final List fixtureList = response.data;

        List<FixtureModel> fixtures = fixtureList
            .map((json) => FixtureModel.fromJson(json))
            .toList();

        fixtures.sort((a, b) => a.date.compareTo(b.date));

        final favSetInt = favoriteIds
            .map((id) => int.tryParse(id))
            .whereType<int>()
            .toSet();

        for (var e in fixtures) {
          if (favSetInt.contains(e.id)) {
            e.favorite = true;
          }
        }

        return fixtures;
      } else {
        throw Exception('โหลดข้อมูลไม่สำเร็จ (Failed to load data)');
      }
    } catch (e) {
      throw Exception('เกิดข้อผิดพลาด: $e (An error occurred: $e)');
    }
  }

  Future<void> addFavorite(FixtureModel fixture) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('กรุณาเข้าสู่ระบบเพื่อเพิ่มรายการโปรด')),
        );
      }
      return;
    }

    await FirebaseFirestore.instance
        .collection('favorites')
        .doc(uid)
        .collection('match')
        .doc(fixture.id.toString())
        .set({
          'fixtureId': fixture.id,
          'homeTeam': fixture.homeTeam,
          'awayTeam': fixture.awayTeam,
          'date': fixture.date.toIso8601String(),
          'stadium': fixture.stadium,

          'title': fixture.title,
          'premier': fixture.premier,
          'homeTeamLogo': fixture.homeTeamLogo,
          'awayTeamLogo': fixture.awayTeamLogo,
        });
  }

  Future<void> removeFavorite(String fixtureId) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('คุณไม่ได้เข้าสู่ระบบ')));
      }
      return;
    }

    await FirebaseFirestore.instance
        .collection('favorites')
        .doc(uid)
        .collection('match')
        .doc(fixtureId)
        .delete();
  }

  Future<void> fetchFavoriteIds() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      setState(() {
        favoriteIds = {};
      });
      return;
    }

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
      print("Error fetching favorite IDs: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เกิดข้อผิดพลาดในการโหลดรายการโปรด: $e')),
        );
      }
    }
  }

  void _launchStore() async {
    final url = Uri.parse(
      'https://play.google.com/store/apps/developer?id=Liverpool+Football+Club',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Fixtures", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.star),
            onPressed: () async {
              await Get.to(() => const FavoritePage());

              // โหลด favoriteId ใหม่ แล้วอัปเดต futureFixtures
              await fetchFavoriteIds();
              setState(() {
                futureFixtures = fetchLfcFixture();
              });
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.red),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: AssetImage('assets/images/logoapp.png'),
                    backgroundColor: Colors.white,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Liverpool FC',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () => Get.toNamed('/'),
            ),
            ListTile(
              leading: const Icon(Icons.newspaper),
              title: const Text('News'),
              onTap: () => Get.toNamed('/news'),
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Players'),
              onTap: () => Get.toNamed('/player'),
            ),
            ListTile(
              leading: const Icon(Icons.event),
              title: const Text('Fixtures'),
              onTap: () => Get.toNamed('/fixture'),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () => Get.toNamed('/profile'),
            ),
            ListTile(
              leading: const Icon(Icons.star),
              title: const Text('Favorite'),
              onTap: () => Get.toNamed('/favorite'),
            ),
            ListTile(
              leading: const Icon(Icons.store),
              title: const Text('LFC Store'),
              onTap: () {
                Navigator.pop(context);
                _launchStore();
              },
            ),
          ],
        ),
      ),
      body: FutureBuilder<List<FixtureModel>>(
        future: futureFixtures,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text("เกิดข้อผิดพลาดในการโหลดข้อมูล: ${snapshot.error}"),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("ไม่มีข้อมูล"));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final fixture = snapshot.data![index];
                final isStarred = fixture.favorite;
                final stringWord = fixture.premier;

                final date = DateFormat(
                  'd MMMM y',
                ).format(fixture.date.toLocal());

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
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
                                    "$stringWord \n $date",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    DateFormat(
                                      'HH:mm',
                                    ).format(fixture.date.toLocal()),
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
                                if (fixture.favorite) {
                                  setState(() {
                                    fixture.favorite = false;
                                    favoriteIds.remove(id);
                                  });
                                  await removeFavorite(id);
                                } else {
                                  setState(() {
                                    fixture.favorite = true;
                                    favoriteIds.add(id);
                                  });
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
          }
        },
      ),
    );
  }
}

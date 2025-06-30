import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/route_manager.dart';
import 'package:intl/intl.dart';
import 'package:lfcfanhub/app/model/fixtureModel.dart';
import 'package:lfcfanhub/app/model/newsmodel.dart';
import 'package:lfcfanhub/app/view/fixture.dart';
import 'package:lfcfanhub/app/view/news.dart';
import 'package:lfcfanhub/app/view/player.dart';
import 'package:lfcfanhub/app/view/profile.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int currentIndex = 0;

  final List<Widget> pages = [
    Text("", style: TextStyle(fontSize: 24)),
    NewsPage(),
    Players(),
    // Fixture(),
    Profile(),
  ];
  final Dio dio = Dio();
  static Future<List<NewsModel>>? futureNews;
  Future<List<NewsModel>> fetchLfcNews() async {
    print("fetch news");
    try {
      final response = await dio.get(
        'https://backend.liverpoolfc.com/lfc-rest-api/news?perPage=20',
      );
      print(response.statusCode);
      if (response.statusCode == 200) {
        final List newsList = response.data['results'];
        return newsList.map((json) => NewsModel.fromJson(json)).toList();
      } else {
        throw Exception('โหลดข่าวไม่สำเร็จ');
      }
    } catch (e) {
      print(e);
      throw Exception('เกิดข้อผิดพลาด: $e');
    }
  }

  Future<List<FixtureModel>>? futureFixtures;
  Future<List<FixtureModel>> fetchLfcFixture() async {
    print("fetch Fixture");
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

        return fixtures;
      } else {
        throw Exception('โหลดข้อมูลไม่สำเร็จ');
      }
    } catch (e) {
      throw Exception('เกิดข้อผิดพลาด: $e');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    futureNews = fetchLfcNews();
    futureFixtures = fetchLfcFixture();
  }

  void navigateTo(int index) {
    setState(() {
      currentIndex = index;
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("LFC ", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.red,
      ),

      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.red),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
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
              onTap: () => Navigator.pop(context),
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
              leading: const Icon(Icons.shopping_cart),
              title: const Text('LFC Store'),
              onTap: () async {
                final Uri url = Uri.parse(
                  'https://play.google.com/store/apps/details?id=com.store.liverpoolfc&hl=th',
                );
                if (!await launchUrl(url)) {
                  throw 'Could not launch $url';
                }
              },
            ),
          ],
        ),
      ),

      body: Column(
        children: [
          Expanded(
            child: FutureBuilder(
              future: futureNews,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text("error");
                } else {
                  return ListView.builder(
                    itemCount: 1,
                    itemBuilder: (context, index) {
                      final title = snapshot.data?[index].title;
                      final image = snapshot.data?[index].image;
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: GestureDetector(
                          onTap: () {
                            Get.toNamed("/news");
                          },
                          child: Card(
                            shape: BeveledRectangleBorder(
                              borderRadius: BorderRadiusGeometry.vertical(),
                            ),
                            child: Column(
                              children: [
                                Container(
                                  height: 220,

                                  width: double.infinity,
                                  color: Colors.blue,
                                  child: Image.network(image ?? "no content"),
                                ),
                                Text(
                                  title ?? "no content",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),

          Expanded(
            child: FutureBuilder<List<FixtureModel>>(
              future: futureFixtures,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(
                    child: Text("เกิดข้อผิดพลาดในการโหลดข้อมูล"),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("ไม่มีข้อมูล"));
                } else {
                  return ListView.builder(
                    itemCount: 1,
                    itemBuilder: (context, index) {
                      final fixture = snapshot.data![index];
                      return GestureDetector(
                        onTap: () {
                          Get.toNamed("/fixture");
                        },
                        child: Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 8,
                          ),
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
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
                                        fixture.homeTeam ?? "",
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    children: [
                                      Text(
                                        fixture.premier +
                                            '\n ' +
                                            DateFormat(
                                              ' d MMMM y',
                                            ).format(fixture.date.toLocal()),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 6),

                                      const SizedBox(height: 6),
                                      Text(
                                        DateFormat(
                                          'HH:mm',
                                        ).format(fixture.date.toLocal()),
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),

                                        textAlign: TextAlign.center,
                                      ),
                                      Text(
                                        'Stadium:  ' + fixture.stadium ?? "",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
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
                                        fixture.awayTeamLogo ?? "",
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
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.red,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          switch (index) {
            case 0:
              Get.toNamed("/");
              break;
            case 1:
              Get.toNamed("/news");
              break;
            case 2:
              Get.toNamed("/player");
              break;
            case 3:
              Get.toNamed("/fixture");
              break;
            case 4:
              Get.toNamed("/profile");
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.newspaper), label: "News"),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: "Players"),
          BottomNavigationBarItem(icon: Icon(Icons.event), label: "Fixture"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}

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
    try {
      final response = await dio.get(
        'https://backend.liverpoolfc.com/lfc-rest-api/news?perPage=20',
      );
      if (response.statusCode == 200) {
        final List newsList = response.data['results'];
        return newsList.map((json) => NewsModel.fromJson(json)).toList();
      } else {
        throw Exception('โหลดข่าวไม่สำเร็จ');
      }
    } catch (e) {
      throw Exception('เกิดข้อผิดพลาด: $e');
    }
  }

  Future<List<FixtureModel>>? futureFixtures;
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
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.red),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const [
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
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () => navigateTo(0),
            ),
            ListTile(
              leading: Icon(Icons.newspaper),
              title: Text('News'),
              onTap: () => navigateTo(1),
            ),
            ListTile(
              leading: Icon(Icons.people),
              title: Text('Players'),
              onTap: () => navigateTo(2),
            ),
            ListTile(
              leading: Icon(Icons.event),
              title: Text('Fixtures'),
              onTap: () => navigateTo(3),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Profile'),
              onTap: () => navigateTo(4),
            ),
            ListTile(
              leading: Icon(Icons.shopping_cart),
              title: Text('LFC Store'),
              onTap: () async {
                final Uri _url = Uri.parse(
                  'https://play.google.com/store/apps/details?id=com.store.liverpoolfc&hl=th',
                );
                if (!await launchUrl(_url)) {}
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

      // pages[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.red,
        currentIndex: currentIndex,
        selectedItemColor: const Color.fromARGB(255, 218, 173, 170),
        unselectedItemColor: const Color.fromARGB(255, 240, 236, 236),
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (index == 0) {
            Get.toNamed("/");
          } else if (index == 1) {
            Get.toNamed("/news");
          } else if (index == 2) {
            Get.toNamed("/player");
          } else if (index == 3) {
            Get.toNamed("/fixture");
          } else if (index == 4) {
            Get.toNamed("/profile");
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

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lfcfanhub/app/model/fixtureModel.dart';
import 'package:lfcfanhub/app/model/newsmodel.dart';
import 'package:lfcfanhub/app/model/playerteam.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final Dio dio = Dio();

  final List<String> imageUrl = [
    'https://www.sosyallig.com/public/uploads/haberler/269f4c2c703c0c733c69f4ae7171869b.jpg',
    'https://st4.depositphotos.com/1980693/21115/i/450/depositphotos_211154964-stock-photo-liverpool-united-kingdom-may-2018.jpg',
    'https://media.istockphoto.com/id/2178126829/photo/liverpool-football-club-anfield-stadium.jpg?s=612x612&w=0&k=20&c=-UxG0dCyM1dm-9Mo8yOL0dN21baOfcbqPrRG9OiO7DY=',
  ];

  Future<List<NewsModel>>? futureNews;
  Future<List<FixtureModel>>? futureFixtures;
  Future<List<PlayerModel>>? futurePlayer;

  @override
  void initState() {
    super.initState();
    futureNews = fetchLfcNews();
    futureFixtures = fetchLfcFixture();
    futurePlayer = fetchLfcPlayer();
  }

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

  Future<List<PlayerModel>> fetchLfcPlayer() async {
    try {
      final response = await dio.get(
        'https://backend.liverpoolfc.com/lfc-rest-api/players?teamSlug=mens',
      );
      if (response.statusCode == 200) {
        final List playerList = response.data;
        return playerList.map((json) => PlayerModel.fromJson(json)).toList();
      } else {
        throw Exception('โหลดข้อมูลนักเตะไม่สำเร็จ');
      }
    } catch (e) {
      throw Exception('เกิดข้อผิดพลาด: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("LFC", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.red,
        iconTheme: IconThemeData(color: Colors.white),
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
          ],
        ),
      ),
      body: ListView(
        children: [
          FutureBuilder<List<NewsModel>>(
            future: futureNews,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(),
                  ),
                );
              } else if (snapshot.hasError ||
                  !snapshot.hasData ||
                  snapshot.data!.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text("ไม่พบข่าว"),
                );
              } else {
                final news = snapshot.data![0];
                return GestureDetector(
                  onTap: () => Get.toNamed("/news"),
                  child: Card(
                    margin: const EdgeInsets.all(12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.network(
                          news.image,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(
                            news.title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
            },
          ),

          FutureBuilder<List<FixtureModel>>(
            future: futureFixtures,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(),
                  ),
                );
              } else if (snapshot.hasError ||
                  !snapshot.hasData ||
                  snapshot.data!.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text("ไม่พบข้อมูลการแข่งขัน"),
                );
              } else {
                final fixture = snapshot.data![0];
                return GestureDetector(
                  onTap: () => Get.toNamed("/fixture"),
                  child: Card(
                    margin: const EdgeInsets.all(12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                Image.network(fixture.homeTeamLogo, height: 40),
                                Text(fixture.homeTeam),
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
                                    fontSize: 11,
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
                                Image.network(fixture.awayTeamLogo, height: 40),
                                Text(fixture.awayTeam),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
            },
          ),

          FutureBuilder<List<PlayerModel>>(
            future: futurePlayer,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(),
                  ),
                );
              } else if (snapshot.hasError ||
                  !snapshot.hasData ||
                  snapshot.data!.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text("ไม่พบข้อมูลนักเตะ"),
                );
              } else {
                final player = snapshot.data![0];
                return GestureDetector(
                  onTap: () => Get.toNamed("/player"),
                  child: Card(
                    margin: const EdgeInsets.all(12),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.red,
                        child: Text(
                          player.shirtNumber,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(player.name),
                      subtitle: Text('Position: ${player.position}'),
                      trailing: Image.network(
                        player.profilepicture,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              }
            },
          ),
          SizedBox(
            height: 165,
            child: PageView.builder(
              itemCount: imageUrl.length,
              controller: PageController(viewportFraction: 1),
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      imageUrl[index],
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                );
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

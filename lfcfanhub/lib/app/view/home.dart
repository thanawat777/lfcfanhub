import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lfcfanhub/app/controller/webview.dart';
import 'package:lfcfanhub/app/model/fixtureModel.dart';
import 'package:lfcfanhub/app/model/newsmodel.dart';
import 'package:lfcfanhub/app/model/playerteam.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:audioplayers/audioplayers.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final Dio dio = Dio();
  final AudioPlayer _player = AudioPlayer();
  bool isPlaying = true;

  final List<String> imageUrl = [
    'https://www.sosyallig.com/public/uploads/haberler/269f4c2c703c0c733c69f4ae7171869b.jpg',
    'https://st4.depositphotos.com/1980693/21115/i/450/depositphotos_211154964-stock-photo-liverpool-united-kingdom-may-2018.jpg',
    'https://media.istockphoto.com/id/2178126829/photo/liverpool-football-club-anfield-stadium.jpg?s=612x612&w=0&k=20&c=-UxG0dCyM1dm-9Mo8yOL0dN21baOfcbqPrRG9OiO7DY=',
  ];

  Future<List<NewsModel>>? futureNews;
  Future<List<FixtureModel>>? futureFixtures;
  Future<List<PlayerModel>>? futurePlayer;
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

  Future<void> _playWelcomeSound() async {
    await _player.play(AssetSource('sound/lfc_fans.mp3'));
  }

  @override
  void initState() {
    super.initState();
    futureNews = fetchLfcNews();
    futureFixtures = fetchLfcFixture();
    futurePlayer = fetchLfcPlayer();
    _playWelcomeSound();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
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
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(isPlaying ? Icons.volume_up : Icons.volume_off),
            onPressed: () async {
              if (isPlaying) {
                await _player.stop();
              } else {
                await _player.play(AssetSource('sound/lfc_fans.mp3'));
              }
              setState(() {
                isPlaying = !isPlaying;
              });
            },
            tooltip: isPlaying ? "หยุดเพลง" : "เล่นเพลง",
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
                                  'Stadium: ${fixture.stadium} ',
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
            height: 200,
            child: PageView.builder(
              itemCount: imageUrl.length,
              controller: PageController(viewportFraction: 1),
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MyWebViewPage(
                          url:
                              'https://www.thisisanfield.com/clubinfo/anfield/stands/',
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        imageUrl[index],
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

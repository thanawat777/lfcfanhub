import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lfcfanhub/app/controller/detailplayers.dart';

import 'package:lfcfanhub/app/model/playerteam.dart';
import 'package:url_launcher/url_launcher.dart';

class Players extends StatefulWidget {
  const Players({super.key});

  @override
  State<Players> createState() => _PlayersState();
}

class _PlayersState extends State<Players> {
  final Dio dio = Dio();

  Future<List<PlayerModel>>? futurePlayer;

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
  void initState() {
    super.initState();
    futurePlayer = fetchLfcPlayer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Players & Staff", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
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
              onTap: () => Get.toNamed('/main', parameters: {"page": "0"}),
            ),
            ListTile(
              leading: const Icon(Icons.newspaper),
              title: const Text('News'),
              onTap: () => Get.toNamed('/main', parameters: {"page": "1"}),
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Players'),
              onTap: () => Get.toNamed('/main', parameters: {"page": "2"}),
            ),
            ListTile(
              leading: const Icon(Icons.event),
              title: const Text('Fixtures'),
              onTap: () => Get.toNamed('/main', parameters: {"page": "3"}),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () => Get.toNamed('/main', parameters: {"page": "4"}),
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
      body: FutureBuilder<List<PlayerModel>>(
        future: futurePlayer,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            print(snapshot.error);
            return Center(child: Text("เกิดข้อผิดพลาดในการโหลดข้อมูล"));
          } else {
            return ListView.separated(
              separatorBuilder: (context, index) => Divider(color: Colors.red),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final player = snapshot.data![index];

                return Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  PlayerDetail(player: player),
                            ),
                          );
                        },
                        child: ListTile(
                          selectedColor: Colors.blue,
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 30,
                            horizontal: 16,
                          ),
                          leading: CircleAvatar(
                            backgroundColor: player.shirtNumber.isNotEmpty
                                ? Colors.red[700]
                                : Colors.white,
                            child: player.shirtNumber.isNotEmpty
                                ? Text(
                                    player.shirtNumber,
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.white,
                                    ),
                                  )
                                : null,
                            backgroundImage: player.shirtNumber.isEmpty
                                ? AssetImage('assets/images/logoapp.png')
                                : null,
                          ),

                          title: Text(
                            player.name,
                            style: TextStyle(fontSize: 20),
                          ),
                          subtitle: Text("Position: ${player.position}"),
                          // trailing: Image.network(
                          //   player.profilepicture,
                          //   width: 100,
                          //   height: 300,
                          // ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 100,
                      height: 100,
                      child: Image.network(
                        player.profilepicture,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                );
              },
            );
          }
        },
      ),
    );
  }
}

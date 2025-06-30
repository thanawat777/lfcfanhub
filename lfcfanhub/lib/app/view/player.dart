import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:lfcfanhub/app/model/playerteam.dart';

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

  @override
  void initState() {
    super.initState();
    futurePlayer = fetchLfcPlayer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Players", style: TextStyle()),
        backgroundColor: Colors.red,
      ),
      body: FutureBuilder<List<PlayerModel>>(
        future: futurePlayer,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("เกิดข้อผิดพลาดในการโหลดข้อมูล"));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final player = snapshot.data![index];
                print(player.name);
                return ListTile(
                  // leading: CircleAvatar(
                  //   child: Text(player.shirtNumber),
                  //   backgroundColor: Colors.redAccent,
                  //   foregroundColor: Colors.white,
                  // ),
                  // title: Text(player.name),
                );
              },
            );
          }
        },
      ),
    );
  }
}

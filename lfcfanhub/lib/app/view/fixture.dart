import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lfcfanhub/app/model/fixtureModel.dart';

class FixturePage extends StatefulWidget {
  const FixturePage({super.key});

  @override
  State<FixturePage> createState() => _FixturePageState();
}

class _FixturePageState extends State<FixturePage> {
  final Dio dio = Dio();

  late Future<List<FixtureModel>>? futureFixtures;

  Future<List<FixtureModel>> fetchLfcFixture() async {
    try {
      final response = await dio.get(
        'https://backend.liverpoolfc.com/lfc-rest-api/fixtures?sort=desc&teamSlug=mens&seasonYear=2025',
      );

      if (response.statusCode == 200) {
        final List fixtureList = response.data['id'];
        return fixtureList.map((json) => FixtureModel.fromJson(json)).toList();
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
    futureFixtures = fetchLfcFixture();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "โปรแกรมแข่งขัน",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
        centerTitle: true,
      ),
      body: FutureBuilder<List<FixtureModel>>(
        future: futureFixtures,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text("เกิดข้อผิดพลาดในการโหลดข้อมูล"));
          } else {
            final fixtures = snapshot.data!;
            return ListView.builder(
              itemCount: fixtures.length,
              itemBuilder: (context, index) {
                final title = snapshot.data?[index].title;
                // final stadium = snapshot.data?[index].stadium;
                // final homeTeam = snapshot.data?[index].homeTeam;
                // final awayTeam = snapshot.data?[index].awayTeam;
                final homeTeamLogo = snapshot.data?[index].homeTeamLogo;

                return Column(
                  children: [
                    Container(
                      height: 220,

                      width: double.infinity,
                      color: Colors.blue,
                      child: Image.network(homeTeamLogo ?? "no content"),
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
                );
              },
            );
          }
          // bottomNavigationBar: BottomNavigationBar(
          //   currentIndex: 3,
          //   backgroundColor: Colors.red,
          //   selectedItemColor: Colors.white,
          //   unselectedItemColor: Colors.white60,
          //   onTap: (index) {
          //     if (index == 0) Get.toNamed("/");
          //     if (index == 1) Get.toNamed("/news");
          //     if (index == 2) Get.toNamed("/player");
          //     if (index == 4) Get.toNamed("/profile");
          //   },
          //   items: const [
          //     BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          //     BottomNavigationBarItem(icon: Icon(Icons.newspaper), label: "News"),
          //     BottomNavigationBarItem(icon: Icon(Icons.people), label: "Players"),
          //     BottomNavigationBarItem(icon: Icon(Icons.event), label: "Fixture"),
          //     BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          //   ],
          // );
        },
      ),
    );
  }
}  
  
  // String formatDate(DateTime dateTime) {
  //   return "${dateTime.day}/${dateTime.month}/${dateTime.year} "
  //       "${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')} น.";
  // }
// }
        
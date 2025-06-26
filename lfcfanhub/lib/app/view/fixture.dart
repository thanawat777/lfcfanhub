import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:lfcfanhub/app/model/fixtureModel.dart';

class Fixture extends StatefulWidget {
  const Fixture({super.key});

  @override
  State<Fixture> createState() => _FixtureState();
}

class _FixtureState extends State<Fixture> {
  int currentIndex = 0;
  final Dio dio = Dio();
  Future<List<FixtureModel>>? futuremodel;
  Future<List<FixtureModel>> fetchLfcFixture() async {
    try {
      final response = await dio.get(
        'https://backend.liverpoolfc.com/lfc-rest-api/fixtures?sort=desc&teamSlug=mens&seasonYear=2025',
      );
      if (response.statusCode == 200) {
        final List fixtureList = response.data['results'];
        return fixtureList.map((json) => FixtureModel.fromJson(json)).toList();
      } else {
        throw Exception('โหลดข่าวไม่สำเร็จ');
      }
    } catch (e) {
      throw Exception('เกิดข้อผิดพลาด: $e');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    futuremodel = fetchLfcFixture();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Fixture", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.red,
      ),
      body: FutureBuilder(
        future: futuremodel,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text("error");
          } else {
            return ListView.builder(
              itemCount: snapshot.data?.length,
              itemBuilder: (context, index) {
                final title = snapshot.data?[index].title;
                final date = snapshot.data?[index].date;
                final stadium = snapshot.data?[index].stadium;
                final homeTeam = snapshot.data?[index].homeTeam;
                final awayTeam = snapshot.data?[index].awayTeam;
                final homeTeamLogo = snapshot.data?[index].homeTeamLogo;
                final awayTeamLogo = snapshot.data?[index].awayTeamLogo;
                final competitionName = snapshot.data?[index].awayTeamLogo;
                final competitionLogo = snapshot.data?[index].awayTeamLogo;
                print(title);
                print(date);
                print(awayTeam);
                print(competitionLogo);

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: () {},
                    child: Card(
                      shape: BeveledRectangleBorder(
                        borderRadius: BorderRadiusGeometry.vertical(),
                      ),
                      child: Column(
                        children: [
                          Container(
                            height: 50,

                            width: double.infinity,
                            color: Colors.blue,
                            child: Image.network(awayTeamLogo ?? "no content"),
                          ),
                          Text(
                            stadium ?? "no content",
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
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.red,
        currentIndex: currentIndex,
        selectedItemColor: const Color.fromARGB(255, 218, 173, 170),
        unselectedItemColor: const Color.fromARGB(255, 240, 236, 236),
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (index == 0) {
            Get.toNamed("/");
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

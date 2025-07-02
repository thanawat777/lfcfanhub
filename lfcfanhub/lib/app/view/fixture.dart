import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';
import 'package:lfcfanhub/app/model/fixtureModel.dart';

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
    super.initState();
    futureFixtures = fetchLfcFixture();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    flutterLocalNotificationsPlugin.initialize(settings);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Fixture", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: FutureBuilder<List<FixtureModel>>(
        future: futureFixtures,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text("เกิดข้อผิดพลาดในการโหลดข้อมูล"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("ไม่มีข้อมูล"));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final fixture = snapshot.data![index];
                final isStarred = starredMatches.contains(index);
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
                                    'Stadium:    ${fixture.stadium}',
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
                              onPressed: () {
                                setState(() {
                                  if (isStarred) {
                                    starredMatches.remove(index);
                                  } else {
                                    starredMatches.add(index);
                                  }
                                });
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

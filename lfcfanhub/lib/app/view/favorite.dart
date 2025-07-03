import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lfcfanhub/app/model/fixtureModel.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  Future<List<FixtureModel>> fetchFavoritesFromFirebase() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return [];

    final snapshot = await FirebaseFirestore.instance
        .collection('favorites')
        .doc(uid)
        .collection('match')
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return FixtureModel(
        id: data['fixtureId'],
        title: data['title'] ?? '',
        homeTeam: data['homeTeam'] ?? '',
        awayTeam: data['awayTeam'] ?? '',
        premier: data['premier'] ?? '',
        date: DateTime.parse(data['date']),
        stadium: data['stadium'] ?? '',
        homeTeamLogo: data['homeTeamLogo'] ?? '',
        awayTeamLogo: data['awayTeamLogo'] ?? '',
        favorite: true,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Favorite Matches",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: FutureBuilder<List<FixtureModel>>(
        future: fetchFavoritesFromFirebase(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text("เกิดข้อผิดพลาดในการโหลดข้อมูล"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("ยังไม่มีแมตช์ที่คุณติดดาว"));
          } else {
            final favoriteFixtures = snapshot.data!;
            return ListView.builder(
              itemCount: favoriteFixtures.length,
              itemBuilder: (context, index) {
                final fixture = favoriteFixtures[index];
                final date = DateFormat(
                  'd MMMM y',
                ).format(fixture.date.toLocal());
                final time = DateFormat('HH:mm').format(fixture.date.toLocal());

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
                                  if (fixture.homeTeamLogo.isNotEmpty)
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
                                    "${fixture.premier}\n$date",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    time,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
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
                                  if (fixture.awayTeamLogo.isNotEmpty)
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

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lfcfanhub/app/model/fixtureModel.dart';

class FavoritePage extends StatelessWidget {
  final List<FixtureModel> favoriteFixtures;

  const FavoritePage({super.key, required this.favoriteFixtures});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Favorite"),
        backgroundColor: Colors.red,
      ),
      body: favoriteFixtures.isEmpty
          ? const Center(child: Text("ยังไม่มีแมตช์ที่ติดดาว"))
          : ListView.builder(
              itemCount: favoriteFixtures.length,
              itemBuilder: (context, index) {
                final fixture = favoriteFixtures[index];
                final date = DateFormat(
                  'd MMM y HH:mm',
                ).format(fixture.date.toLocal());

                return Card(
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
                                      'd MMMM y',
                                    ).format(fixture.date.toLocal()),
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
                              Image.network(fixture.awayTeamLogo, height: 40),
                              Text(fixture.awayTeam),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

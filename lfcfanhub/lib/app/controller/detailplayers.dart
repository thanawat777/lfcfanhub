import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

import 'package:lfcfanhub/app/model/playerteam.dart';

class PlayerDetail extends StatelessWidget {
  final PlayerModel player;

  const PlayerDetail({super.key, required this.player});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(player.name), backgroundColor: Colors.red),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.white,
                backgroundImage: NetworkImage(player.profilepicture),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                "No: ${player.shirtNumber}",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Center(
              child: Text(
                'Position: ${player.position}',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            Text("Date of Birth: ${player.dateOfBirth}"),
            const SizedBox(height: 8),
            Text("Place of Birth: ${player.placeOfBirth}"),
            const SizedBox(height: 8),
            Text("Nationality: ${player.nationality}"),
            const SizedBox(height: 8),
            Text("Honors: ${player.honors}"),
            const SizedBox(height: 16),
            Text("Biography:", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Html(data: "<p>${player.bio}</p>"),
          ],
        ),
      ),
    );
  }
}

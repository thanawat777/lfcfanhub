import 'package:flutter/material.dart';
import 'package:lfcfanhub/app/view/fixture.dart';
import 'package:lfcfanhub/app/view/news.dart';
import 'package:lfcfanhub/app/view/player.dart';
import 'package:lfcfanhub/app/view/profile.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int currentIndex = 0;

  final List<Widget> pages = [
    Text("", style: TextStyle(fontSize: 24)),
    News(),
    Players(),
    Fixture(),
    Profile(),
  ];

  void navigateTo(int index) {
    setState(() {
      currentIndex = index;
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("LFC Fan Hub", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.red,
      ),

      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.red),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const [
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
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () => navigateTo(0),
            ),
            ListTile(
              leading: Icon(Icons.newspaper),
              title: Text('News'),
              onTap: () => navigateTo(1),
            ),
            ListTile(
              leading: Icon(Icons.people),
              title: Text('Players'),
              onTap: () => navigateTo(2),
            ),
            ListTile(
              leading: Icon(Icons.event),
              title: Text('Fixtures'),
              onTap: () => navigateTo(3),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Profile'),
              onTap: () => navigateTo(4),
            ),
          ],
        ),
      ),

      body: pages[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.red,
        currentIndex: currentIndex,
        selectedItemColor: const Color.fromARGB(255, 218, 173, 170),
        unselectedItemColor: const Color.fromARGB(255, 240, 236, 236),
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
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

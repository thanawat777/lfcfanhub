import 'package:flutter/material.dart';
import 'package:lfcfanhub/app/view/fixture.dart';
import 'package:lfcfanhub/app/view/login.dart';
import 'package:lfcfanhub/app/view/news.dart';
import 'package:lfcfanhub/app/view/player.dart';
import 'package:lfcfanhub/app/view/profile.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isloading = false;

  Future<void> lfc() async {
    if (isloading == true) {
      return;
    } else {
      setState(() {
        isloading = true;
      });
    }

    setState(() {
      isloading = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("LFC Fan Hub", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.red,
      ),

      body: Card(),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.newspaper), label: "News"),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_box),
            label: "Player",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.logout), label: "Fixture"),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_box),
            label: "profile",
          ),
        ],
        currentIndex: 0,
        onTap: (value) async {
          if (value == 4) {
            // await FirebaseAuth.instance.signOut();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => Profile()),
            );
          }
          if (value == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Fixture()),
            );
          }
          if (value == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Players()),
            );
          }
          if (value == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => News()),
            );
          }

          if (value == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Home()),
            );
          }
        },
      ),
    );
  }
}

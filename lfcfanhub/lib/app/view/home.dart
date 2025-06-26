import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/route_manager.dart';
import 'package:lfcfanhub/app/model/newsmodel.dart';
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
    NewsPage(),
    Players(),
    // Fixture(),
    Profile(),
  ];
  final Dio dio = Dio();
  static Future<List<NewsModel>>? future;
  Future<List<NewsModel>> fetchLfcNews() async {
    try {
      final response = await dio.get(
        'https://backend.liverpoolfc.com/lfc-rest-api/news?perPage=20',
      );
      if (response.statusCode == 200) {
        final List newsList = response.data['results'];
        return newsList.map((json) => NewsModel.fromJson(json)).toList();
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
    future = fetchLfcNews();
  }

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
        title: Text("LFC ", style: TextStyle(color: Colors.white)),
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

      body: FutureBuilder(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text("error");
          } else {
            return ListView.builder(
              itemCount: 1,
              itemBuilder: (context, index) {
                final title = snapshot.data?[index].title;
                final image = snapshot.data?[index].image;
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: () {
                      Get.toNamed("/news");
                    },
                    child: Card(
                      shape: BeveledRectangleBorder(
                        borderRadius: BorderRadiusGeometry.vertical(),
                      ),
                      child: Column(
                        children: [
                          Container(
                            height: 220,

                            width: double.infinity,
                            color: Colors.blue,
                            child: Image.network(image ?? "no content"),
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
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),

      // pages[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.red,
        currentIndex: currentIndex,
        selectedItemColor: const Color.fromARGB(255, 218, 173, 170),
        unselectedItemColor: const Color.fromARGB(255, 240, 236, 236),
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (index == 1) {
            Get.toNamed("/news");
          } else if (index == 2) {
            Get.toNamed("/player");
          } else if (index == 3) {
            Get.toNamed("/fixture");
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

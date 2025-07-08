import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:get/route_manager.dart';
import 'package:lfcfanhub/app/model/newsmodel.dart';
import 'package:lfcfanhub/app/controller/webview.dart';
import 'package:url_launcher/url_launcher.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({super.key});

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  int currentIndex = 0;
  final Dio dio = Dio();
  Future<List<NewsModel>>? future;
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

  void _launchStore() async {
    final url = Uri.parse(
      'https://play.google.com/store/apps/developer?id=Liverpool+Football+Club',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    future = fetchLfcNews();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("News", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.red,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.red),
              child: Column(
                children: [
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
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () => Get.toNamed('/main', parameters: {"page": "0"}),
            ),
            ListTile(
              leading: const Icon(Icons.newspaper),
              title: const Text('News'),
              onTap: () => Get.toNamed('/main', parameters: {"page": "1"}),
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Players'),
              onTap: () => Get.toNamed('/main', parameters: {"page": "2"}),
            ),
            ListTile(
              leading: const Icon(Icons.event),
              title: const Text('Fixtures'),
              onTap: () => Get.toNamed('/main', parameters: {"page": "3"}),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () => Get.toNamed('/main', parameters: {"page": "4"}),
            ),
            ListTile(
              leading: const Icon(Icons.star),
              title: const Text('Favorite'),
              onTap: () => Get.toNamed('/favorite'),
            ),
            ListTile(
              leading: const Icon(Icons.store),
              title: const Text('LFC Store'),
              onTap: () {
                Navigator.pop(context);
                _launchStore();
              },
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
              itemCount: snapshot.data?.length,
              itemBuilder: (context, index) {
                final title = snapshot.data?[index].title;
                final image = snapshot.data?[index].image;
                final url = snapshot.data?[index].url;

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              MyWebViewPage(url: url.toString()),
                        ),
                      );
                    },
                    child: Card(
                      shape: BeveledRectangleBorder(),
                      child: Column(
                        children: [
                          Container(
                            height: 220,
                            width: double.infinity,

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
    );
  }
}

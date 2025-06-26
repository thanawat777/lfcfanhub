import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:lfcfanhub/app/model/newsmodel.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({super.key});

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    future = fetchLfcNews();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: () {},
                    child: Card(
                      shape: BeveledRectangleBorder(),
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
    );
  }
}

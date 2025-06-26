import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:lfcfanhub/app/view/fixture.dart';
import 'package:lfcfanhub/app/view/home.dart';

import 'package:lfcfanhub/app/view/login.dart';
import 'package:lfcfanhub/app/view/news.dart';
import 'package:lfcfanhub/app/view/register.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      initialRoute: "/",
      getPages: [
        GetPage(name: "/", page: () => Home()),
        GetPage(name: '/news', page: () => NewsPage()),
        GetPage(name: '/fixture', page: () => Fixture()),
      ],
    );
  }
}

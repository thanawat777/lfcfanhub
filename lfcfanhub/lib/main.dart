import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:get_storage/get_storage.dart';
import 'package:lfcfanhub/app/view/favorite.dart';

import 'package:lfcfanhub/app/view/fixture.dart';
import 'package:lfcfanhub/app/view/home.dart';

import 'package:lfcfanhub/app/view/login.dart';
import 'package:lfcfanhub/app/view/news.dart';
import 'package:lfcfanhub/app/view/player.dart';
import 'package:lfcfanhub/app/view/profile.dart';

import 'package:lfcfanhub/service/storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await GetStorage.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: Autwrap(),
      getPages: [
        GetPage(name: "/", page: () => Home()),
        GetPage(name: "/login", page: () => Login()),
        GetPage(name: '/news', page: () => NewsPage()),
        GetPage(name: '/player', page: () => Players()),
        GetPage(name: '/profile', page: () => Profile()),
        GetPage(name: '/fixture', page: () => FixturePage()),
        GetPage(name: '/favorite', page: () => FavoritePage()),
      ],
    );
  }
}

class Autwrap extends StatelessWidget {
  const Autwrap({super.key});

  @override
  Widget build(BuildContext context) {
    if (UserStorage().isLogin()) {
      return Home();
    } else {
      return Login();
    }
  }
}

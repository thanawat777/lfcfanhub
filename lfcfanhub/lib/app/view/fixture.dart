import 'package:flutter/material.dart';

class Fixture extends StatefulWidget {
  const Fixture({super.key});

  @override
  State<Fixture> createState() => _FixtureState();
}

class _FixtureState extends State<Fixture> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text("Fixture")));
  }
}

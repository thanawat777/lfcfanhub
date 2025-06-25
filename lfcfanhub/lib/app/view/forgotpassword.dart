import 'package:flutter/material.dart';

class ForGotpassword extends StatefulWidget {
  const ForGotpassword({super.key});

  @override
  State<ForGotpassword> createState() => _ForGotpasswordState();
}

class _ForGotpasswordState extends State<ForGotpassword> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text('Forgot?Password')));
  }
}

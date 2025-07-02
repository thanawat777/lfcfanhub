import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lfcfanhub/app/view/login.dart';

class ForGotpassword extends StatefulWidget {
  const ForGotpassword({super.key});

  @override
  State<ForGotpassword> createState() => _ForGotpasswordState();
}

class _ForGotpasswordState extends State<ForGotpassword> {
  late TextEditingController emailController;

  @override
  void initState() {
    super.initState();

    emailController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();

    emailController.dispose();
  }

  Future<void> regsetPassword() async {
    // final inputEmail = emailController.text.trim();
    // await FirebaseAuth.instance.sendPasswordResetEmail(email: inputEmail);
    Get.defaultDialog(
      title: 'Resent Email complete',
      titleStyle: TextStyle(color: Colors.white),
      middleText: "plese check your Email",
      backgroundColor: Colors.red,
      textConfirm: "OKAY",

      onConfirm: () {
        Get.toNamed("/login");
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Reset Password"), centerTitle: true),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),

          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(30.0),
                child: Image.asset('assets/images/Liverpool.png', height: 200),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  'Enter your Email ',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                height: 40,
                child: TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Email",
                  ),
                ),
              ),
              SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("Cancel"),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: regsetPassword,
                    child: Text("Reset Password"),

                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

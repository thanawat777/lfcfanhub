import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text("Profile")));
  }
}

class ProfileState extends State<Profile> {
  final String uid = FirebaseAuth.instance.currentUser!.uid;
  late TextEditingController nameController;
  late TextEditingController imageURLController;
  late TextEditingController emailController;
  bool _isEdit = false;

  Future<void> fetchUser() async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> doc = await FirebaseFirestore
          .instance
          .collection('members')
          .doc(uid)
          .get();
      if (doc.exists) {
        setState(() {
          nameController.text = doc.data()?["name"] ?? "no name";
          imageURLController.text =
              doc.data()?["profile_picture"] ??
              "https://i.pinimg.com/originals/cb/a3/e2/cba3e2e64077bea3cef082d6f3bba8e0.jpg ";
          emailController.text = doc.data()?["email"] ?? "no email";
        });
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("something went wrong")));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("something went wrong")));
    }
  }

  Future<void> updateData() async {
    final image = imageURLController.text.trim();
    final name = nameController.text.trim();
    try {
      await FirebaseFirestore.instance.collection("memberes").doc(uid).update({
        "name": name,
        "profile_picture": image,
      });
    } catch (e) {
      // Get.snackBar("warning, Some ting when wrong");
    }
  }

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    imageURLController = TextEditingController();
    emailController = TextEditingController();
    fetchUser();
  }

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    imageURLController.dispose();
    emailController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("profile"), centerTitle: true),
      body: Center(
        child: Column(
          children: [
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: NetworkImage(imageURLController.text),
                ),
              ),
            ),
            _isEdit
                ? Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: nameController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: imageURLController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  )
                : Text(
                    "name ${nameController.text}",
                    style: TextStyle(fontSize: 25),
                  ),
            Text(
              "email ${emailController.text}",
              style: TextStyle(fontSize: 20),
            ),
            Text("uid : $uid"),
            _isEdit
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _isEdit = !_isEdit;
                          });
                        },
                        child: Text("Cancel"),
                      ),
                      ElevatedButton(onPressed: () {}, child: Text("OK")),
                    ],
                  )
                : ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isEdit = !_isEdit;
                      });
                    },
                    child: Text("Edit"),
                  ),
          ],
        ),
      ),
    );
  }
}

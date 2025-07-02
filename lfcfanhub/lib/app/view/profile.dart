import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lfcfanhub/app/view/home.dart';
import 'package:lfcfanhub/app/view/login.dart';
import 'package:lfcfanhub/service/storage.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final String uid = FirebaseAuth.instance.currentUser?.uid ?? "";
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController imageURLController;

  bool _isEdit = false;
  File? _pickedImage;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    emailController = TextEditingController();
    imageURLController = TextEditingController();

    fetchUser();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    imageURLController.dispose();

    super.dispose();
  }

  Future<void> fetchUser() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('members')
          .doc(uid)
          .get();
      if (doc.exists) {
        final data = doc.data();
        setState(() {
          nameController.text = data?['name'] ?? 'No name';
          emailController.text = data?['email'] ?? 'No email';
          imageURLController.text = data?['email'] ?? 'No email';
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("เกิดข้อผิดพลาด: $e")));
    }
  }

  Future<void> updateData() async {
    try {
      await FirebaseFirestore.instance.collection("members").doc(uid).update({
        "name": nameController.text.trim(),
      });
      setState(() {
        _isEdit = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("อัปเดตสำเร็จ")));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("เกิดข้อผิดพลาด: $e")));
    }
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _pickedImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _isEdit ? pickImage : null,
              child: CircleAvatar(
                radius: 100,
                backgroundImage: _pickedImage != null
                    ? FileImage(_pickedImage!)
                    : NetworkImage(imageURLController.text) as ImageProvider,
              ),
            ),
            const SizedBox(height: 16),
            _isEdit
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Name",
                      ),
                    ),
                  )
                : Text(
                    "Name: ${nameController.text}",
                    style: const TextStyle(fontSize: 20),
                  ),
            const SizedBox(height: 8),
            Text(
              "Email: ${emailController.text}",
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 16),
            _isEdit
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () => setState(() => _isEdit = false),
                        child: const Text("Cancel"),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: updateData,
                        child: const Text("Save"),
                      ),
                    ],
                  )
                : ElevatedButton(
                    onPressed: () => setState(() => _isEdit = true),
                    child: const Text("Edit Profile"),
                  ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.red,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        currentIndex: 1,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: "Profile",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.logout), label: "Log out"),
        ],
        onTap: (index) async {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const Home()),
            );
          } else if (index == 2) {
            await FirebaseAuth.instance.signOut();
            UserStorage().box.remove('user');
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const Login()),
            );
          }
        },
      ),
    );
  }
}

import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lfcfanhub/app/controller/upload_image.dart';
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
  TextEditingController nameController = TextEditingController();
  // TextEditingController emailController = TextEditingController();
  // TextEditingController imageURLController = TextEditingController();

  bool _isEdit = false;
  File? _pickedImage;

  @override
  void initState() {
    super.initState();
    nameController.text = UserStorage().box.read("name") ?? "";
    print(UserStorage().box.read("name"));
  }

  @override
  void dispose() {
    nameController.dispose();

    super.dispose();
  }

  Future<void> updateData() async {
    UserStorage().box.write("name", nameController.text.trim());
    final imageUrl = await UploadImg().uploadImage(_pickedImage);
    UserStorage().box.write('image', imageUrl);

    try {
      await FirebaseFirestore.instance.collection("Member").doc(uid).update({
        "name": nameController.text.trim(),
        'image': imageUrl,
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
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 80,
                    backgroundImage: _pickedImage != null
                        ? FileImage(_pickedImage!)
                        : NetworkImage(UserStorage().box.read("image"))
                              as ImageProvider,
                  ),
                  if (_isEdit)
                    Positioned(bottom: 0, right: 0, child: Icon(Icons.edit)),
                ],
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
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      nameController.text,
                      style: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
            const SizedBox(height: 8),
            Text(
              "email: ${UserStorage().box.read("email")}",
              style: const TextStyle(fontSize: 20, color: Colors.grey),
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
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => setState(() => _isEdit = true),
                      child: const Text(
                        "Edit Profile",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Get.toNamed('/favorite');
              },
              child: const Text(
                "Favorite Match",
                style: TextStyle(color: Colors.white),
              ),
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
            UserStorage().logout();
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

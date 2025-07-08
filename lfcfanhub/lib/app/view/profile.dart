import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lfcfanhub/app/controller/upload_image.dart';
import 'package:lfcfanhub/service/storage.dart';
import 'package:url_launcher/url_launcher.dart';

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
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
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => setState(() => _isEdit = true),
                      icon: const Icon(Icons.edit),
                      label: const Text(
                        "Edit Profile",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),

            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Get.toNamed('/favorite');
              },
              icon: const Icon(Icons.star),
              label: const Text(
                "Favorite Match",
                style: TextStyle(color: Colors.white),
              ),
            ),

            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  UserStorage().logout();
                  Get.offAllNamed('/login');
                },
                icon: const Icon(Icons.logout),
                label: const Text("Logout"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

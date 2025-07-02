import 'package:get_storage/get_storage.dart';

class UserStorage {
  final box = GetStorage();
  void collectUserId(value) {
    box.write('user', value);
  }

  bool isLogin() {
    if (box.read('user') == null) {
      return false;
    } else {
      return true;
    }
  }

  void collectUserdata(Map<String, dynamic>? data) {
    box.write('name', data?["name"]);
    box.write('email', data?['email']);
    box.write('image', data?['image']);
  }

  void logout() {
    box.remove('name');
    box.remove('user');
    box.remove('email');
    box.remove('image');
  }
}

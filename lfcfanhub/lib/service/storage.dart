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
}

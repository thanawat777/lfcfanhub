import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lfcfanhub/service/storage.dart';

class UploadImg {
  final ImagePicker imagePicker = ImagePicker();
  final getConnect = GetConnect();

  Future<String> pickimage() async {
    final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      return pickedFile.path;
    } else {
      return "no image has picker";
    }
  }

  Future<String> uploadImage(File? image) async {
    if (image == null) {
      return UserStorage().box.read("image");
    }
    final cloudUrl = 'https://api.cloudinary.com/v1_1/dbffnm2ha/image/upload';
    final setFile = MultipartFile(image, filename: image.path.split("/").last);
    final response = await getConnect.post(
      cloudUrl,
      FormData({'upload_preset': 'lfcfanhub', 'file': setFile}),
    );
    return response.body['secure_url'];
  }
}

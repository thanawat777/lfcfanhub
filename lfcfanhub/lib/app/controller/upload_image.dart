import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UploadImg {
  File? _image;
  final ImagePicker imagePicker = ImagePicker();

  Future<String> pickimage() async {
    final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      return pickedFile.path;
    } else {
      return "no image has picker";
    }
  }

  Future<void> uploadImage(String imagePath) async {
    final File? imgfile = File(imagePath);
    if (imgfile == null) {
      return;
    }
    final cloudUrl = 'https://api.cloudinary.com/v1_1/dbffnm2ha/image/upload';
  }
}

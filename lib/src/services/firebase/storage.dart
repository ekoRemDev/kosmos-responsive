import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import "package:image_picker/image_picker.dart";

// import 'package:mime_type/mime_type.dart';

class FirebaseStorageController {
  final FirebaseStorage instance = FirebaseStorage.instance;

  Future<File?> selectFile(String userId) async {
    final result = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (result == null) {
      return null;
    } else {
      downloadUrl(File(result.path), userId);
    }
    return null;
  }

  Future<String?> downloadUrl(
    File profilPicture,
    String userId,
  ) async {
    Reference ref = FirebaseStorage.instance.ref().child('users/$userId/profil/').child('/profil-picture.png');

    try {
      await ref.putFile(profilPicture);
      final url = await ref.getDownloadURL();
      return url.toString();
    } catch (error) {
      if (kDebugMode) {
        print(error);
      }
      return null;
    }
  }

  // Future<String> loadImage(String path) async {
  //   if (path.isEmpty) return "";
  //   return await instance.ref(path).getDownloadURL();
  // }

  // Future<String?> uploadUserImage(String userId) async {
  //   if (kIsWeb) {
  //     // MediaInfo? mediaInfo = await ImagePickerWeb.getImageInfo;
  //     final ImagePicker _picker = ImagePicker();
  //     XFile? image = await _picker.pickImage(source: ImageSource.gallery);
  //     if (image != null) {
  //       var f = await image.readAsBytes();
  //       // setState(() {
  //       //   _file = File("a");
  //       //   webImage = f;
  //       // });
  //     } else {
  //       // showToast("No file selected");
  //     }
  //   } else {
  //     // showToast("Permission not granted");
  //   }

  //   //   if (mediaInfo != null) {
  //   //     String? mimeType = mime(basename(mediaInfo.fileName!));
  //   //     //change fileName
  //   //     Reference ref = FirebaseStorage.instance.ref().child('users/$userId/profil/').child('/profil-picture.png');

  //   //     final metadata = SettableMetadata(
  //   //       contentType: mimeType,
  //   //     );
  //   //     UploadTask uploadTask = ref.putData(mediaInfo.data!, metadata);
  //   //     var task = await uploadTask;
  //   //     String urlPicture = await task.ref.getDownloadURL();
  //   //     return urlPicture;
  //   //   }
  //   // }
  //   return null;
  // }
}

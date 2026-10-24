import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';

class ImageHelper {
  static final _picker = ImagePicker();

  static Future<List<XFile>> pickMultiple({int limit = 5}) async {
    return await _picker.pickMultiImage(imageQuality: 80, limit: limit);
  }

  static Future<XFile?> pickSingle() async {
    return await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
  }

  // Helper pour lire les bytes (Web & Mobile)
  static Future<Uint8List> readBytes(XFile file) async {
    return await file.readAsBytes();
  }
}
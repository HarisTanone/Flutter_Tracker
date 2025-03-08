import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class ImageHelper {
  static Future<File?> takePicture() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? photo = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (photo != null) {
        final appDir = await getApplicationDocumentsDirectory();
        final fileName =
            'speedometer_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final savedImage =
            await File(photo.path).copy('${appDir.path}/$fileName');
        return savedImage;
      }
    } catch (e) {
      return null;
    }
    return null;
  }
}

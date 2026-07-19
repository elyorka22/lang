import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Pick a photo and copy it into app documents for a stable avatar path.
class AvatarPicker {
  AvatarPicker();

  final ImagePicker _picker = ImagePicker();

  Future<String?> pickAndSave({required ImageSource source}) async {
    final file = await _picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (file == null) return null;

    final dir = await getApplicationDocumentsDirectory();
    final avatarDir = Directory(p.join(dir.path, 'avatars'));
    if (!avatarDir.existsSync()) {
      await avatarDir.create(recursive: true);
    }

    final ext = p.extension(file.path).isEmpty ? '.jpg' : p.extension(file.path);
    final destPath = p.join(
      avatarDir.path,
      'me_${DateTime.now().millisecondsSinceEpoch}$ext',
    );
    await File(file.path).copy(destPath);
    return destPath;
  }
}

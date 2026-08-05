import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {
  final supabase = Supabase.instance.client;

  Future<String> uploadMaterial(File file) async {
    try {
      final fileName =
          "${DateTime.now().millisecondsSinceEpoch}_${basename(file.path)}";

      await supabase.storage.from("learning-materials").upload(fileName, file);

      return fileName;
    } catch (e) {
      debugPrint("Storage upload error: $e");
      rethrow;
    }
  }

  Future<void> deleteMaterial(String filePath) async {
    await supabase.storage.from("learning-materials").remove([filePath]);
  }
}

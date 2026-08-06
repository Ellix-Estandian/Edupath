import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/presentation.dart';

class PresentationService {
  // Android Emulator
  // static const String baseUrl = "http://10.0.2.2:8000";

  // Physical Android Phone
  static const String baseUrl = "http://192.168.1.4:8000";
  final supabase = Supabase.instance.client;

  Future<File> generatePresentation({
    required String courseId,
    required String topic,
  }) async {
    final uri = Uri.parse(
      "$baseUrl/generate-presentation?"
      "course_id=$courseId"
      "&topic=${Uri.encodeComponent(topic)}",
    );

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception("Failed to generate presentation.");
    }

    final directory = await getApplicationDocumentsDirectory();

    final file = File(
      "${directory.path}/presentation_${DateTime.now().millisecondsSinceEpoch}.pptx",
    );

    await file.writeAsBytes(response.bodyBytes);

    return file;
  }

  Future<List<Presentation>> getPresentations(String courseId) async {
    final response = await supabase
        .from("presentations")
        .select()
        .eq("course_id", courseId)
        .order("created_at", ascending: false);

    return response
        .map<Presentation>(
          (json) => Presentation.fromJson(json),
        )
        .toList();
  }

  Future<Presentation> savePresentation({
    required String courseId,
    required String topic,
    required File file,
  }) async {
    final fileName =
        "${DateTime.now().millisecondsSinceEpoch}_${file.path.split("/").last}";

    // Upload the file to Supabase Storage
    await supabase.storage.from("presentations").upload(fileName, file);

    // Save metadata in the database
    final response = await supabase
        .from("presentations")
        .insert({
          "course_id": courseId,
          "title": topic,
          "topic": topic,
          "file_path": fileName,
        })
        .select()
        .single();

    return Presentation.fromJson(response);
  }

  Future<File> downloadPresentation(String filePath) async {
    final bytes =
        await supabase.storage.from("presentations").download(filePath);

    final directory = await getApplicationDocumentsDirectory();

    final file = File(
      "${directory.path}/${filePath.split("/").last}",
    );

    await file.writeAsBytes(bytes);

    return file;
  }
}

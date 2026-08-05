import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class PresentationService {
  // Android Emulator
  // static const String baseUrl = "http://10.0.2.2:8000";

  // Physical Android Phone
  static const String baseUrl = "http://192.168.1.4:8000";

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
}

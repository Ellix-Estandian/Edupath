import 'dart:convert';

import 'package:http/http.dart' as http;

class AIService {
  // Android Emulator
  // static const String baseUrl = "http://10.0.2.2:8000";

  // Physical Android Phone
  static const String baseUrl = "http://192.168.1.4:8000";

  Future<String> ask({
    required String question,
    required String courseId,
  }) async {
    final uri = Uri.parse(
      "$baseUrl/rag?"
      "course_id=$courseId"
      "&question=${Uri.encodeComponent(question)}",
    );

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception("AI server error");
    }

    final data = jsonDecode(response.body);

    return data["answer"];
  }
}

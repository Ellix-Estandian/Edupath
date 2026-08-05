import 'dart:convert';

import 'package:http/http.dart' as http;

class AIQuizService {
  // Android Emulator
  // static const String baseUrl = "http://10.0.2.2:8000";

  // Physical Device
  static const String baseUrl = "http://192.168.1.4:8000";

  Future<List<dynamic>> generateQuiz({
    required String courseId,
    required String topic,
    int numberOfQuestions = 5,
  }) async {
    final uri = Uri.parse(
      "$baseUrl/generate-quiz?"
      "course_id=$courseId"
      "&topic=${Uri.encodeComponent(topic)}"
      "&num_questions=$numberOfQuestions",
    );

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception("Failed to generate quiz.");
    }

    final data = jsonDecode(response.body);

    if (data["success"] != true) {
      throw Exception(data["raw_output"]);
    }

    return data["quiz"];
  }

  Future<void> saveQuiz({
    required String courseId,
    required String title,
    required List<dynamic> questions,
  }) async {
    final uri = Uri.parse("$baseUrl/save-generated-quiz");

    final response = await http.post(
      uri,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "course_id": courseId,
        "title": title,
        "questions": questions,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to save quiz.");
    }

    final data = jsonDecode(response.body);

    if (data["success"] != true) {
      throw Exception("Unable to save quiz.");
    }
  }
}

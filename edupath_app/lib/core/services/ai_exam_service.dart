import 'dart:convert';

import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class AIExamService {
  // Android Emulator
  static const String baseUrl = "http://10.0.2.2:8000";

  // Physical Device
  // static const String baseUrl = "http://192.168.1.14:8000";

  Future<String> generateExam({
    required String courseId,
    required String topic,
    required List<Map<String, dynamic>> parts,
  }) async {
    final uri = Uri.parse(
      "$baseUrl/generate-exam?"
      "course_id=$courseId"
      "&topic=${Uri.encodeComponent(topic)}"
      "&parts=${Uri.encodeComponent(jsonEncode(parts))}",
    );

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception("Failed to generate examination.");
    }

    final data = jsonDecode(response.body);

    return data["exam"];
  }

  Future<File> downloadExam({
    required String courseId,
    required String topic,
    required List<Map<String, dynamic>> parts,
    String? examTitle,
  }) async {
    final uri = Uri.parse(
      "$baseUrl/download-exam?"
      "course_id=$courseId"
      "&topic=${Uri.encodeComponent(topic)}"
      "&parts=${Uri.encodeComponent(jsonEncode(parts))}"
      "&title=${Uri.encodeComponent(examTitle ?? '')}",
    );

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception("Unable to download examination.");
    }

    final directory = await getApplicationDocumentsDirectory();

    final file = File(
      "${directory.path}/generated_exam.docx",
    );

    await file.writeAsBytes(response.bodyBytes);

    return file;
  }

  Future<File> downloadExamPdf({
    required String courseId,
    required String topic,
    required List<Map<String, dynamic>> parts,
    String? examTitle,
  }) async {
    final uri = Uri.parse(
      "$baseUrl/download-exam-pdf?"
      "course_id=$courseId"
      "&topic=${Uri.encodeComponent(topic)}"
      "&parts=${Uri.encodeComponent(jsonEncode(parts))}"
      "&title=${Uri.encodeComponent(examTitle ?? '')}",
    );

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception("Unable to download PDF examination.");
    }

    final directory = await getApplicationDocumentsDirectory();

    final file = File(
      "${directory.path}/generated_exam.pdf",
    );

    await file.writeAsBytes(response.bodyBytes);

    return file;
  }

  Future<String> generateLearningObjective({
    required String courseId,
    required String topic,
    String? materialId,
  }) async {
    final uri = Uri.parse(
      '$baseUrl/generate-learning-objective?'
      'course_id=$courseId&topic=${Uri.encodeComponent(topic)}'
      '&material_id=${Uri.encodeComponent(materialId ?? '')}',
    );
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Failed to generate a learning objective.');
    }
    return jsonDecode(response.body)['objective'] as String;
  }
}

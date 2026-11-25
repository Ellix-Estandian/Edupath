import 'dart:convert';

import 'package:http/http.dart' as http;

class AIBackendService {
  static const String baseUrl = "http://10.0.2.2:8000";

  Future<void> indexMaterial({
    required String materialId,
    required String pdfPath,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/index-material"),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "material_id": materialId,
        "pdf_path": pdfPath,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to index material");
    }
  }
}

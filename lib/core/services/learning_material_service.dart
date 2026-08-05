import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/learning_material.dart';

class LearningMaterialService {
  final supabase = Supabase.instance.client;

  Future<List<LearningMaterial>> getMaterials(String courseId) async {
    final response = await supabase
        .from("learning_materials")
        .select()
        .eq("course_id", courseId)
        .order("created_at");

    print(response.toString());

    return response
        .map<LearningMaterial>(
          (json) => LearningMaterial.fromJson(json),
        )
        .toList();
  }

  Future<void> updateMaterial({
    required String id,
    required String fileName,
    required String filePath,
    required String fileType,
  }) async {
    await supabase.from("learning_materials").update({
      "file_name": fileName,
      "file_path": filePath,
      "file_type": fileType,
    }).eq("id", id);
  }

  Future<void> deleteMaterial(String id) async {
    await supabase.from("learning_materials").delete().eq("id", id);
  }
}

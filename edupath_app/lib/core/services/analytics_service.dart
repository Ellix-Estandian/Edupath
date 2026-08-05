import 'package:supabase_flutter/supabase_flutter.dart';

class AnalyticsService {
  final supabase = Supabase.instance.client;

  Future<int> totalCourses() async {
    final result = await supabase.from("courses").select("id");

    return result.length;
  }

  Future<int> totalStudents() async {
    final result =
        await supabase.from("profiles").select("id").eq("role", "student");

    return result.length;
  }

  Future<int> totalMaterials() async {
    final result = await supabase.from("learning_materials").select("id");

    return result.length;
  }

  Future<int> totalQuizzes() async {
    final result = await supabase.from("quizzes").select("id");

    return result.length;
  }
}

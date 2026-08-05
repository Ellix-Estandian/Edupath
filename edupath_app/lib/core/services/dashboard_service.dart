import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardService {
  final supabase = Supabase.instance.client;

  Future<Map<String, int>> getProfessorStats() async {
    final user = supabase.auth.currentUser!;

    // Courses
    final courses =
        await supabase.from("courses").select("id").eq("professor_id", user.id);

    final courseIds = courses.map((e) => e["id"]).toList();

    // Students
    int students = 0;

    if (courseIds.isNotEmpty) {
      final enrollments = await supabase
          .from("enrollments")
          .select("student_id")
          .inFilter("course_id", courseIds);

      students = enrollments.map((e) => e["student_id"]).toSet().length;
    }

    // Quizzes
    int quizzes = 0;

    if (courseIds.isNotEmpty) {
      final quizList = await supabase
          .from("quizzes")
          .select("id")
          .inFilter("course_id", courseIds);

      quizzes = quizList.length;
    }

    // Learning Materials
    int materials = 0;

    if (courseIds.isNotEmpty) {
      final docs = await supabase
          .from("learning_materials")
          .select("id")
          .inFilter("course_id", courseIds);

      materials = docs.length;
    }

    return {
      "courses": courses.length,
      "students": students,
      "quizzes": quizzes,
      "materials": materials,
    };
  }
}

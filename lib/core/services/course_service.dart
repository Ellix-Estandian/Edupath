import '../../models/course.dart';
import 'supabase_service.dart';

class CourseService {
  final supabase = SupabaseService.client;

  Future<void> createCourse({
    required String title,
    required String description,
  }) async {
    final user = supabase.auth.currentUser!;

    await supabase.from("courses").insert({
      "professor_id": user.id,
      "title": title,
      "description": description,
    });
  }

  Future<List<Course>> getProfessorCourses() async {
    final user = supabase.auth.currentUser!;

    final response = await supabase
        .from("courses")
        .select()
        .eq("professor_id", user.id)
        .order("created_at");

    return response.map<Course>((json) => Course.fromJson(json)).toList();
  }

  Future<void> deleteCourse(String id) async {
    await supabase.from("courses").delete().eq("id", id);
  }

  Future<void> updateCourse({
    required String id,
    required String title,
    required String description,
  }) async {
    await supabase.from("courses").update({
      "title": title,
      "description": description,
    }).eq("id", id);
  }
}

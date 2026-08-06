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

  Future<double> getAverageQuizScore() async {
    final response = await supabase.from("quiz_attempts").select("score");

    if (response.isEmpty) {
      return 0;
    }

    double total = 0;

    for (final row in response) {
      total += (row["score"] as num).toDouble();
    }

    return total / response.length;
  }

  Future<List<Map<String, dynamic>>> getRecentQuizAttempts() async {
    final user = supabase.auth.currentUser!;

    // Get the professor's course IDs
    final courses =
        await supabase.from("courses").select("id").eq("professor_id", user.id);

    final courseIds = courses.map((e) => e["id"]).toList();

    if (courseIds.isEmpty) return [];

    // Get quizzes for those courses
    final quizzes = await supabase
        .from("quizzes")
        .select("id, title")
        .inFilter("course_id", courseIds);

    if (quizzes.isEmpty) return [];

    final quizIds = quizzes.map((e) => e["id"]).toList();

    final quizMap = {
      for (final q in quizzes) q["id"]: q["title"],
    };

    // Get recent attempts
    final attempts = await supabase
        .from("quiz_attempts")
        .select("student_id, quiz_id, score, total_items, submitted_at")
        .inFilter("quiz_id", quizIds)
        .order("submitted_at", ascending: false)
        .limit(5);

    // Get student names
    final studentIds = attempts.map((e) => e["student_id"]).toSet().toList();

    final profiles = studentIds.isEmpty
        ? []
        : await supabase
            .from("profiles")
            .select("id, full_name")
            .inFilter("id", studentIds);

    final profileMap = {
      for (final p in profiles) p["id"]: p["full_name"] ?? "Unknown Student",
    };

    return attempts.map<Map<String, dynamic>>((attempt) {
      return {
        "student": profileMap[attempt["student_id"]] ?? "Unknown Student",
        "quiz": quizMap[attempt["quiz_id"]] ?? "Unknown Quiz",
        "score": "${attempt["score"]}/${attempt["total_items"]}",
        "submitted_at": attempt["submitted_at"],
      };
    }).toList();
  }

  Future<List<Map<String, dynamic>>> getQuizPerformance() async {
    final user = supabase.auth.currentUser!;

    // Professor's courses
    final courses =
        await supabase.from("courses").select("id").eq("professor_id", user.id);

    final courseIds = courses.map((e) => e["id"]).toList();

    if (courseIds.isEmpty) return [];

    // Quizzes
    final quizzes = await supabase
        .from("quizzes")
        .select("id, title")
        .inFilter("course_id", courseIds);

    if (quizzes.isEmpty) return [];

    List<Map<String, dynamic>> result = [];

    for (final quiz in quizzes) {
      final attempts = await supabase
          .from("quiz_attempts")
          .select("score")
          .eq("quiz_id", quiz["id"]);

      double average = 0;

      if (attempts.isNotEmpty) {
        double total = 0;

        for (final attempt in attempts) {
          total += (attempt["score"] as num).toDouble();
        }

        average = total / attempts.length;
      }

      result.add({
        "title": quiz["title"],
        "average": average,
      });
    }

    return result;
  }

  Future<Map<String, dynamic>> getStudentStats() async {
    final user = supabase.auth.currentUser!;

    // Enrolled courses
    final enrollments = await supabase
        .from("enrollments")
        .select("course_id")
        .eq("student_id", user.id);

    // Quiz attempts
    final attempts = await supabase
        .from("quiz_attempts")
        .select("score, total_items")
        .eq("student_id", user.id);

    int totalCourses = enrollments.length;
    int quizzesCompleted = attempts.length;

    double average = 0;
    int bestScore = 0;

    if (attempts.isNotEmpty) {
      double totalPercentage = 0;

      for (final attempt in attempts) {
        final score = attempt["score"] as int;
        final total = attempt["total_items"] as int;

        final percent = (score / total) * 100;

        totalPercentage += percent;

        if (percent > bestScore) {
          bestScore = percent.round();
        }
      }

      average = totalPercentage / attempts.length;
    }

    return {
      "courses": totalCourses,
      "completed": quizzesCompleted,
      "average": average,
      "best": bestScore,
    };
  }

  Future<List<Map<String, dynamic>>> getStudentRecentAttempts() async {
    final user = supabase.auth.currentUser!;

    final response = await supabase
        .from("quiz_attempts")
        .select("""
        score,
        total_items,
        submitted_at,
        quizzes(
          title
        )
      """)
        .eq("student_id", user.id)
        .order("submitted_at", ascending: false)
        .limit(5);

    return List<Map<String, dynamic>>.from(response);
  }
}

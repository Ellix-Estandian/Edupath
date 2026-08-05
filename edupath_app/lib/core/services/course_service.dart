import 'dart:math';

import 'package:flutter/foundation.dart';

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
      "course_code": generateCourseCode(),
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

  Future<void> joinCourse(String courseCode) async {
    final user = supabase.auth.currentUser!;

    // Find the course
    final course = await supabase
        .from("courses")
        .select()
        .eq("course_code", courseCode.toUpperCase())
        .single();

    // Check if already enrolled
    final existing = await supabase
        .from("enrollments")
        .select()
        .eq("student_id", user.id)
        .eq("course_id", course["id"]);

    if (existing.isNotEmpty) {
      throw Exception("You are already enrolled in this course.");
    }

    // Enroll the student
    await supabase.from("enrollments").insert({
      "student_id": user.id,
      "course_id": course["id"],
    });
  }

  Future<List<Course>> getStudentCourses() async {
    final user = supabase.auth.currentUser!;

    final enrollments = await supabase
        .from("enrollments")
        .select("course_id")
        .eq("student_id", user.id);

    debugPrint("Enrollments: $enrollments");

    if (enrollments.isEmpty) {
      return [];
    }

    final courseIds =
        enrollments.map<String>((e) => e["course_id"] as String).toList();

    debugPrint("Course IDs: $courseIds");

    final response =
        await supabase.from("courses").select().inFilter("id", courseIds);

    debugPrint("Courses Response: $response");

    return response.map<Course>((json) => Course.fromJson(json)).toList();
  }

  Future<List<Course>> getAllCourses() async {
    final response =
        await supabase.from("courses").select().order("created_at");

    return response.map<Course>((json) => Course.fromJson(json)).toList();
  }

  Future<void> enrollCourse(String courseId) async {
    final user = supabase.auth.currentUser!;

    await supabase.from("enrollments").insert({
      "course_id": courseId,
      "student_id": user.id,
    });
  }

  String generateCourseCode() {
    const chars = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";
    final random = Random();

    return List.generate(
      6,
      (_) => chars[random.nextInt(chars.length)],
    ).join();
  }
}

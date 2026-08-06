import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/profile.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import '../../models/profile_stats.dart';

class ProfileService {
  final supabase = Supabase.instance.client;

  Future<Profile> getProfile() async {
    final user = supabase.auth.currentUser!;

    final data =
        await supabase.from("profiles").select().eq("id", user.id).single();

    return Profile.fromJson(data);
  }

  Future<void> updateProfile(String fullName) async {
    final user = supabase.auth.currentUser!;

    await supabase.from("profiles").update({
      "full_name": fullName,
    }).eq("id", user.id);
  }

  Future<void> logout() async {
    await supabase.auth.signOut();
  }

  Future<void> updatePassword(String password) async {
    await supabase.auth.updateUser(
      UserAttributes(password: password),
    );
  }

  Future<void> uploadAvatar() async {
    final user = supabase.auth.currentUser!;

    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result == null) return;

    final file = File(result.files.single.path!);

    final path = "${user.id}.jpg";

    await supabase.storage.from("avatars").upload(
          path,
          file,
          fileOptions: const FileOptions(
            upsert: true,
          ),
        );

    final url = supabase.storage.from("avatars").getPublicUrl(path);

    await supabase.from("profiles").update({
      "avatar_url": url,
    }).eq("id", user.id);
  }

  Future<ProfileStats> getProfessorStats() async {
    final user = supabase.auth.currentUser!;

    // Professor's courses
    final courses =
        await supabase.from("courses").select().eq("professor_id", user.id);

    // Get course IDs
    final courseIds = courses.map((course) => course["id"]).toList();

    int quizCount = 0;
    int materialCount = 0;
    double average = 0;

    if (courseIds.isNotEmpty) {
      // Quizzes belonging to the professor's courses
      final quizzes = await supabase
          .from("quizzes")
          .select()
          .inFilter("course_id", courseIds);

      quizCount = quizzes.length;

      // Learning materials
      final materials = await supabase
          .from("learning_materials")
          .select()
          .inFilter("course_id", courseIds);

      materialCount = materials.length;

      // Quiz IDs
      final quizIds = quizzes.map((quiz) => quiz["id"]).toList();

      if (quizIds.isNotEmpty) {
        final attempts = await supabase
            .from("quiz_attempts")
            .select("score")
            .inFilter("quiz_id", quizIds);

        if (attempts.isNotEmpty) {
          final total = attempts.fold<double>(
            0,
            (sum, item) => sum + (item["score"] as num).toDouble(),
          );

          average = total / attempts.length;
        }
      }
    }

    return ProfileStats(
      courses: courses.length,
      quizzes: quizCount,
      materials: materialCount,
      average: average,
    );
  }
}

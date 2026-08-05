import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationService {
  final supabase = Supabase.instance.client;

  Future<void> createNotification({
    required String userId,
    required String title,
    required String message,
  }) async {
    await supabase.from("notifications").insert({
      "user_id": userId,
      "title": title,
      "message": message,
    });
  }

  Future<List<Map<String, dynamic>>> getNotifications() async {
    final user = supabase.auth.currentUser!;

    final response = await supabase
        .from("notifications")
        .select()
        .eq("user_id", user.id)
        .order("created_at", ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> markAsRead(String id) async {
    await supabase.from("notifications").update({"is_read": true}).eq("id", id);
  }

  Future<int> unreadCount() async {
    final user = supabase.auth.currentUser!;

    final response = await supabase
        .from("notifications")
        .select("id")
        .eq("user_id", user.id)
        .eq("is_read", false);

    return response.length;
  }
}

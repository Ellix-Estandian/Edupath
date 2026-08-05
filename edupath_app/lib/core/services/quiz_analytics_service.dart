import 'package:supabase_flutter/supabase_flutter.dart';

class QuizAnalyticsService {
  final supabase = Supabase.instance.client;

  Future<Map<String, dynamic>> getStatistics(String quizId) async {
    final attempts = await supabase
        .from("quiz_attempts")
        .select("score,total_items")
        .eq("quiz_id", quizId);

    if (attempts.isEmpty) {
      return {
        "average": 0.0,
        "highest": 0,
        "lowest": 0,
        "attempts": 0,
      };
    }

    double total = 0;
    int highest = 0;
    int lowest = 999999;

    for (final attempt in attempts) {
      final score = (attempt["score"] as num).toInt();

      total += score;

      if (score > highest) {
        highest = score;
      }

      if (score < lowest) {
        lowest = score;
      }
    }

    return {
      "average": total / attempts.length,
      "highest": highest,
      "lowest": lowest,
      "attempts": attempts.length,
    };
  }
}

class QuizAttempt {
  final String id;
  final String quizId;
  final String studentId;
  final int score;
  final int totalItems;
  final DateTime submittedAt;

  QuizAttempt({
    required this.id,
    required this.quizId,
    required this.studentId,
    required this.score,
    required this.totalItems,
    required this.submittedAt,
  });

  factory QuizAttempt.fromJson(Map<String, dynamic> json) {
    return QuizAttempt(
      id: json["id"] as String,
      quizId: json["quiz_id"] as String,
      studentId: json["student_id"] as String,
      score: json["score"] as int,
      totalItems: json["total_items"] as int,
      submittedAt: DateTime.parse(json["submitted_at"]),
    );
  }
}

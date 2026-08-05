class QuizQuestion {
  final String id;
  final String quizId;
  final String question;
  final DateTime createdAt;

  QuizQuestion({
    required this.id,
    required this.quizId,
    required this.question,
    required this.createdAt,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: json["id"] as String,
      quizId: json["quiz_id"] as String,
      question: json["question"] as String,
      createdAt: DateTime.parse(json["created_at"]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "quiz_id": quizId,
      "question": question,
    };
  }
}

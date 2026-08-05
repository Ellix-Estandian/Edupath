class QuizAttemptAnswer {
  final String id;
  final String attemptId;
  final String questionId;
  final String selectedAnswerId;

  QuizAttemptAnswer({
    required this.id,
    required this.attemptId,
    required this.questionId,
    required this.selectedAnswerId,
  });

  factory QuizAttemptAnswer.fromJson(Map<String, dynamic> json) {
    return QuizAttemptAnswer(
      id: json["id"] as String,
      attemptId: json["attempt_id"] as String,
      questionId: json["question_id"] as String,
      selectedAnswerId: json["selected_answer_id"] as String,
    );
  }
}

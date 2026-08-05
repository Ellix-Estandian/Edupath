class QuizAnswer {
  final String id;
  final String questionId;
  final String answer;
  final bool isCorrect;

  QuizAnswer({
    required this.id,
    required this.questionId,
    required this.answer,
    required this.isCorrect,
  });

  factory QuizAnswer.fromJson(Map<String, dynamic> json) {
    return QuizAnswer(
      id: json["id"] as String,
      questionId: json["question_id"] as String,
      answer: json["answer"] as String,
      isCorrect: json["is_correct"] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "question_id": questionId,
      "answer": answer,
      "is_correct": isCorrect,
    };
  }
}

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/quiz.dart';
import '../../models/quiz_answer.dart';
import '../../models/quiz_question.dart';

class QuizService {
  final supabase = Supabase.instance.client;

  // ===========================
  // QUIZ CRUD
  // ===========================

  Future<List<Quiz>> getQuizzes(String courseId) async {
    final response = await supabase
        .from("quizzes")
        .select()
        .eq("course_id", courseId)
        .order("created_at");

    return response.map<Quiz>((e) => Quiz.fromJson(e)).toList();
  }

  Future<void> createQuiz({
    required String courseId,
    required String title,
    required String description,
  }) async {
    await supabase.from("quizzes").insert({
      "course_id": courseId,
      "title": title,
      "description": description,
    });
  }

  Future<void> updateQuiz({
    required String id,
    required String title,
    required String description,
  }) async {
    await supabase.from("quizzes").update({
      "title": title,
      "description": description,
    }).eq("id", id);
  }

  Future<void> deleteQuiz(String id) async {
    await supabase.from("quizzes").delete().eq("id", id);
  }

  // ===========================
  // QUESTIONS
  // ===========================

  Future<List<QuizQuestion>> getQuestions(String quizId) async {
    final response = await supabase
        .from("quiz_questions")
        .select()
        .eq("quiz_id", quizId)
        .order("created_at");

    return response.map<QuizQuestion>((e) => QuizQuestion.fromJson(e)).toList();
  }

  Future<void> createQuestion({
    required String quizId,
    required String question,
  }) async {
    await supabase.from("quiz_questions").insert({
      "quiz_id": quizId,
      "question": question,
    });
  }

  Future<void> updateQuestion({
    required String id,
    required String question,
  }) async {
    await supabase.from("quiz_questions").update({
      "question": question,
    }).eq("id", id);
  }

  Future<void> deleteQuestion(String id) async {
    await supabase.from("quiz_questions").delete().eq("id", id);
  }

  // ===========================
  // ANSWERS
  // ===========================

  Future<List<QuizAnswer>> getAnswers(String questionId) async {
    final response = await supabase
        .from("quiz_answers")
        .select()
        .eq("question_id", questionId);

    return response.map<QuizAnswer>((e) => QuizAnswer.fromJson(e)).toList();
  }

  Future<void> createAnswer({
    required String questionId,
    required String answer,
    required bool isCorrect,
  }) async {
    if (isCorrect) {
      await supabase
          .from("quiz_answers")
          .update({"is_correct": false}).eq("question_id", questionId);
    }

    await supabase.from("quiz_answers").insert({
      "question_id": questionId,
      "answer": answer,
      "is_correct": isCorrect,
    });
  }

  Future<void> updateAnswer({
    required String id,
    required String answer,
    required bool isCorrect,
  }) async {
    if (isCorrect) {
      final existing = await supabase
          .from("quiz_answers")
          .select("question_id")
          .eq("id", id)
          .single();

      final questionId = existing["question_id"];

      await supabase
          .from("quiz_answers")
          .update({"is_correct": false}).eq("question_id", questionId);
    }

    await supabase.from("quiz_answers").update({
      "answer": answer,
      "is_correct": isCorrect,
    }).eq("id", id);
  }

  Future<void> deleteAnswer(String id) async {
    await supabase.from("quiz_answers").delete().eq("id", id);
  }

  // ===========================
  // STUDENT
  // ===========================

  Future<String> createAttempt({
    required String quizId,
    required String studentId,
    required int totalItems,
  }) async {
    final response = await supabase
        .from("quiz_attempts")
        .insert({
          "quiz_id": quizId,
          "student_id": studentId,
          "score": 0,
          "total_items": totalItems,
        })
        .select()
        .single();

    return response["id"];
  }

  Future<void> saveStudentAnswer({
    required String attemptId,
    required String questionId,
    required String selectedAnswerId,
  }) async {
    await supabase.from("quiz_attempt_answers").insert({
      "attempt_id": attemptId,
      "question_id": questionId,
      "selected_answer_id": selectedAnswerId,
    });
  }

  Future<void> updateScore({
    required String attemptId,
    required int score,
  }) async {
    await supabase.from("quiz_attempts").update({
      "score": score,
    }).eq("id", attemptId);
  }
}

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/services/quiz_service.dart';
import '../../../models/quiz.dart';
import '../../../models/quiz_answer.dart';
import '../../../models/quiz_question.dart';
import 'quiz_result_page.dart';

class TakeQuizPage extends StatefulWidget {
  final Quiz quiz;

  const TakeQuizPage({
    super.key,
    required this.quiz,
  });

  @override
  State<TakeQuizPage> createState() => _TakeQuizPageState();
}

class _TakeQuizPageState extends State<TakeQuizPage> {
  final QuizService service = QuizService();

  List<QuizQuestion> questions = [];

  final Map<String, List<QuizAnswer>> answers = {};

  final Map<String, String> selectedAnswers = {};

  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadQuiz();
  }

  Future<void> loadQuiz() async {
    questions = await service.getQuestions(widget.quiz.id);

    for (final question in questions) {
      answers[question.id] = await service.getAnswers(question.id);
    }

    if (!mounted) return;

    setState(() {
      loading = false;
    });
  }

  Future<void> submitQuiz() async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) return;

    int score = 0;

    final attemptId = await service.createAttempt(
      quizId: widget.quiz.id,
      studentId: user.id,
      totalItems: questions.length,
    );

    for (final question in questions) {
      final selectedId = selectedAnswers[question.id];

      if (selectedId == null) {
        continue;
      }

      await service.saveStudentAnswer(
        attemptId: attemptId,
        questionId: question.id,
        selectedAnswerId: selectedId,
      );

      final correct = answers[question.id]!.firstWhere((e) => e.isCorrect);

      if (correct.id == selectedId) {
        score++;
      }
    }

    await service.updateScore(
      attemptId: attemptId,
      score: score,
    );

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => QuizResultPage(
          score: score,
          total: questions.length,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.quiz.title),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final question in questions) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      question.question,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...answers[question.id]!.map(
                      (answer) => RadioListTile<String>(
                        value: answer.id,
                        groupValue: selectedAnswers[question.id],
                        title: Text(answer.answer),
                        onChanged: (value) {
                          setState(() {
                            selectedAnswers[question.id] = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
          ElevatedButton(
            onPressed: submitQuiz,
            child: const Text("Submit Quiz"),
          ),
        ],
      ),
    );
  }
}

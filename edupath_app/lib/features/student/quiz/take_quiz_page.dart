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
    if (selectedAnswers.length != questions.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please answer all questions before submitting."),
        ),
      );
      return;
    }

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
    final theme = Theme.of(context);

    if (loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final answeredCount = selectedAnswers.length;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(widget.quiz.title),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Hero header with progress
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.primaryContainer
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(14)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.quiz.title,
                  style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.quiz.description,
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: Colors.white70),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // small progress summary
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: questions.isEmpty
                            ? 0
                            : answeredCount / questions.length,
                        backgroundColor: Colors.white24,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text('${answeredCount}/${questions.length}',
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: Colors.white)),
                  ],
                ),
              ],
            ),
          ),

          // Quiz content
          Expanded(
            child: RefreshIndicator(
              onRefresh: loadQuiz,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: questions.length,
                itemBuilder: (context, qIndex) {
                  final question = questions[qIndex];
                  final opts = answers[question.id] ?? [];

                  return Column(
                    children: [
                      Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 14,
                                    backgroundColor: theme.colorScheme.primary
                                        .withOpacity(0.12),
                                    child: Text('${qIndex + 1}',
                                        style: theme.textTheme.labelSmall
                                            ?.copyWith(
                                                color:
                                                    theme.colorScheme.primary)),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      question.question,
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                              fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 12),

                              // Answers
                              ...opts.map((answer) {
                                final selected =
                                    selectedAnswers[question.id] == answer.id;
                                return InkWell(
                                  onTap: () {
                                    setState(() {
                                      selectedAnswers[question.id] = answer.id;
                                    });
                                  },
                                  child: Container(
                                    margin:
                                        const EdgeInsets.symmetric(vertical: 6),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 12),
                                    decoration: BoxDecoration(
                                      color: selected
                                          ? theme.colorScheme.primary
                                              .withOpacity(0.08)
                                          : null,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                          color: selected
                                              ? theme.colorScheme.primary
                                              : theme.dividerColor),
                                    ),
                                    child: Row(
                                      children: [
                                        Radio<String>(
                                          value: answer.id,
                                          groupValue:
                                              selectedAnswers[question.id],
                                          onChanged: (v) {
                                            setState(() {
                                              selectedAnswers[question.id] = v!;
                                            });
                                          },
                                          activeColor:
                                              theme.colorScheme.primary,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(child: Text(answer.answer)),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),

                              if (opts.isEmpty) ...[
                                const SizedBox(height: 8),
                                Text('No answers available for this question.',
                                    style: theme.textTheme.labelSmall),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  );
                },
              ),
            ),
          ),

          // Submit bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.0),
                      child: Text('Cancel'),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final submit = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Submit Quiz'),
                          content: const Text(
                              'Are you sure you want to submit your answers?'),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel')),
                            ElevatedButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Submit')),
                          ],
                        ),
                      );

                      if (submit == true) {
                        await submitQuiz();
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child:
                          Text('Submit (${answeredCount}/${questions.length})'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

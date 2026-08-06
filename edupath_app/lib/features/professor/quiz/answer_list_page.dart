import 'package:flutter/material.dart';

import '../../../core/services/quiz_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../models/quiz_answer.dart';
import '../../../models/quiz_question.dart';
import 'create_answer_page.dart';
import 'edit_answer_page.dart';

class AnswerListPage extends StatefulWidget {
  final QuizQuestion question;

  const AnswerListPage({
    super.key,
    required this.question,
  });

  @override
  State<AnswerListPage> createState() => _AnswerListPageState();
}

class _AnswerListPageState extends State<AnswerListPage> {
  final QuizService _quizService = QuizService();

  List<QuizAnswer> answers = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadAnswers();
  }

  Future<void> loadAnswers() async {
    setState(() => loading = true);

    answers = await _quizService.getAnswers(widget.question.id);

    if (!mounted) return;

    setState(() => loading = false);
  }

  Future<void> deleteAnswer(String id) async {
    await _quizService.deleteAnswer(id);
    loadAnswers();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Answer Choices'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final created = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CreateAnswerPage(question: widget.question),
            ),
          );

          if (created == true) {
            loadAnswers();
          }
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add choice'),
      ),
      body: SafeArea(
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.accent],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(AppRadius.xlarge),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(Icons.fact_check_rounded,
                                color: Colors.white),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Answer choices',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Review and manage the available answers for this question.',
                                  style: TextStyle(
                                      color: Colors.white70, height: 1.4),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: answers.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                              child: Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.xlarge),
                                  border: Border.all(color: AppColors.border),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 16,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryLight,
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                      child: const Icon(
                                        Icons.chat_bubble_outline_rounded,
                                        size: 48,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    const Text(
                                      'No answer choices yet',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Add the first answer option to start building your quiz.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: AppColors.textSecondary),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(18, 0, 18, 90),
                            itemCount: answers.length,
                            itemBuilder: (context, index) {
                              final answer = answers[index];
                              final isCorrect = answer.isCorrect;

                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.large),
                                  border: Border.all(color: AppColors.border),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 12,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: (isCorrect
                                                ? AppColors.success
                                                : AppColors.textMuted)
                                            .withOpacity(0.14),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: Icon(
                                        isCorrect
                                            ? Icons.check_circle_rounded
                                            : Icons
                                                .radio_button_unchecked_rounded,
                                        color: isCorrect
                                            ? AppColors.success
                                            : AppColors.textMuted,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            answer.answer,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            isCorrect
                                                ? 'Correct answer'
                                                : 'Incorrect answer',
                                            style: const TextStyle(
                                                color: AppColors.textSecondary),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () async {
                                        final updated = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                EditAnswerPage(answer: answer),
                                          ),
                                        );

                                        if (updated == true) {
                                          loadAnswers();
                                        }
                                      },
                                      icon: const Icon(Icons.edit_rounded,
                                          color: AppColors.primary),
                                    ),
                                    IconButton(
                                      onPressed: () => deleteAnswer(answer.id),
                                      icon: const Icon(Icons.delete_rounded,
                                          color: AppColors.danger),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
      ),
    );
  }
}

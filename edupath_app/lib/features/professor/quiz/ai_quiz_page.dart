import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../core/services/ai_quiz_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../models/course.dart';

class AIQuizPage extends StatefulWidget {
  final Course course;

  const AIQuizPage({
    super.key,
    required this.course,
  });

  @override
  State<AIQuizPage> createState() => _AIQuizPageState();
}

class _AIQuizPageState extends State<AIQuizPage> {
  final AIQuizService service = AIQuizService();
  final topicController = TextEditingController();

  bool loading = false;
  List<dynamic> questions = [];

  Future<void> generate() async {
    if (topicController.text.trim().isEmpty) return;

    setState(() => loading = true);

    try {
      final dynamic result = await service.generateQuiz(
        courseId: widget.course.id,
        topic: topicController.text.trim(),
      );

      // Normalize result to a List of question maps
      List<dynamic> parsed = [];

      if (result is String) {
        // Try to decode JSON string
        try {
          final decoded = jsonDecode(result as String);
          if (decoded is List)
            parsed = decoded;
          else if (decoded is Map) {
            // Some APIs wrap questions under a key like 'questions'
            if (decoded['questions'] is List)
              parsed = decoded['questions'];
            else
              parsed = [decoded];
          } else {
            parsed = [
              {'question': result.toString(), 'answer': ''}
            ];
          }
        } catch (_) {
          // Not JSON — assume plain text with newline-delimited Q/A (best-effort)
          final lines = (result as String)
              .split('\n')
              .where((l) => l.trim().isNotEmpty)
              .toList();
          parsed = lines.map((l) => {'question': l, 'answer': ''}).toList();
        }
      } else if (result is List) {
        parsed = result;
      } else if (result is Map) {
        if (result['questions'] is List)
          parsed = result['questions'];
        else
          parsed = [result];
      } else {
        parsed = [
          {'question': result.toString(), 'answer': ''}
        ];
      }

      setState(() => questions = parsed);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }

    if (mounted) {
      setState(() => loading = false);
    }
  }

  Future<void> saveQuiz() async {
    if (questions.isEmpty) return;

    try {
      await service.saveQuiz(
        courseId: widget.course.id,
        title: topicController.text.trim(),
        questions: questions,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Quiz saved successfully!')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Quiz Generator'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.accent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.xlarge),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.quiz_rounded,
                          color: Colors.white, size: 24),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Generate an AI quiz',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Enter a topic and generate a polished quiz in seconds.',
                      style: TextStyle(color: Colors.white70, height: 1.5),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.large),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quiz setup',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: topicController,
                      decoration: const InputDecoration(
                        labelText: 'Topic',
                        prefixIcon: Icon(Icons.topic_rounded),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: loading ? null : generate,
                        icon: loading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.auto_awesome_rounded),
                        label:
                            Text(loading ? 'Generating...' : 'Generate Quiz'),
                      ),
                    ),
                    if (questions.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: saveQuiz,
                          icon: const Icon(Icons.save_rounded),
                          label: const Text('Save Quiz'),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 18),
              if (questions.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(AppRadius.large),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.lightbulb_rounded,
                          color: Theme.of(context).colorScheme.primary),
                      const SizedBox(height: 8),
                      Text(
                        'Your generated quiz will appear here.',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Add a topic and generate a focused set of quiz questions.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.color
                                ?.withOpacity(0.8)),
                      ),
                    ],
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: questions.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, index) {
                    final q = questions[index];
                    // Support both Map and simple String representations
                    final questionText = (q is Map)
                        ? (q['question'] ?? q['text'] ?? q.toString())
                        : q.toString();
                    final answerText =
                        (q is Map) ? (q['answer'] ?? q['answers'] ?? '') : '';

                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(AppRadius.large),
                        border:
                            Border.all(color: Theme.of(context).dividerColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            questionText.toString(),
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          if (answerText != null &&
                              answerText.toString().isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 8),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .secondary
                                    .withOpacity(0.08),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                'Answer: ${answerText.toString()}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

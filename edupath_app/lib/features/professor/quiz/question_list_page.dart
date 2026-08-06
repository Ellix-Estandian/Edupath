import 'package:flutter/material.dart';

import '../../../core/services/quiz_service.dart';
import '../../../models/quiz.dart';
import '../../../models/quiz_question.dart';
import 'create_question_page.dart';
import 'edit_question_page.dart';
import 'answer_list_page.dart';

class QuestionListPage extends StatefulWidget {
  final Quiz quiz;

  const QuestionListPage({
    super.key,
    required this.quiz,
  });

  @override
  State<QuestionListPage> createState() => _QuestionListPageState();
}

class _QuestionListPageState extends State<QuestionListPage> {
  final QuizService service = QuizService();
  List<QuizQuestion> questions = [];
  List<QuizQuestion> filtered = [];

  final searchController = TextEditingController();

  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadQuestions();
    searchController.addListener(_applyFilter);
  }

  void _applyFilter() {
    final q = searchController.text.trim().toLowerCase();
    if (q.isEmpty) {
      setState(() => filtered = List.from(questions));
      return;
    }

    setState(() {
      filtered = questions
          .where((it) => it.question.toLowerCase().contains(q))
          .toList();
    });
  }

  Future<void> loadQuestions() async {
    setState(() => loading = true);

    questions = await service.getQuestions(widget.quiz.id);

    if (!mounted) return;

    setState(() {
      loading = false;
      filtered = List.from(questions);
    });
  }

  Future<void> _confirmAndDelete(QuizQuestion question) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete question'),
        content: const Text(
            'Are you sure you want to delete this question? This action cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (ok != true) return;

    await service.deleteQuestion(question.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Question deleted')));
    await loadQuestions();
  }

  @override
  void dispose() {
    searchController.removeListener(_applyFilter);
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.quiz.title),
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        foregroundColor: theme.colorScheme.onBackground,
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          final created = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CreateQuestionPage(
                quiz: widget.quiz,
              ),
            ),
          );

          if (created == true) {
            await loadQuestions();
          }
        },
      ),
      body: RefreshIndicator(
        onRefresh: loadQuestions,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary.withOpacity(0.08),
                      theme.colorScheme.secondary.withOpacity(0.03)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.list_alt, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Questions',
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Manage questions for this quiz. Tap a card to view answers.',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Chip(
                      label: Text('${questions.length}'),
                      backgroundColor: theme.colorScheme.surface,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Search
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: TextField(
                    controller: searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search questions',
                      border: InputBorder.none,
                      icon: Icon(Icons.search),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Content
              if (loading) ...[
                const SizedBox(height: 40),
                const Center(child: CircularProgressIndicator()),
              ] else if (filtered.isEmpty) ...[
                const SizedBox(height: 40),
                Center(
                    child: Text('No questions found',
                        style: theme.textTheme.bodyMedium)),
              ] else ...[
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, index) {
                    final question = filtered[index];

                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor:
                                  theme.colorScheme.primary.withOpacity(0.12),
                              child: Text('${index + 1}',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.primary)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: InkWell(
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          AnswerListPage(question: question),
                                    ),
                                  );
                                  await loadQuestions();
                                },
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(question.question,
                                        style: theme.textTheme.bodyLarge),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Text('View answers',
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                                    color: theme.hintColor)),
                                        const SizedBox(width: 12),
                                        Text('ID: ${question.id}',
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                                    color: theme.hintColor)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              children: [
                                IconButton(
                                  tooltip: 'Edit question',
                                  icon: const Icon(Icons.edit),
                                  onPressed: () async {
                                    final updated = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => EditQuestionPage(
                                            question: question),
                                      ),
                                    );

                                    if (updated == true) {
                                      await loadQuestions();
                                    }
                                  },
                                ),
                                IconButton(
                                  tooltip: 'Delete question',
                                  icon: const Icon(Icons.delete),
                                  onPressed: () => _confirmAndDelete(question),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

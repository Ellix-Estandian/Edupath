import 'package:flutter/material.dart';

import '../../../core/services/quiz_service.dart';
import '../../../models/course.dart';
import '../../../models/quiz.dart';
import 'create_quiz_page.dart';
import 'edit_quiz_page.dart';
import 'question_list_page.dart';
import 'quiz_results_page.dart';

class QuizListPage extends StatefulWidget {
  final Course course;

  const QuizListPage({
    super.key,
    required this.course,
  });

  @override
  State<QuizListPage> createState() => _QuizListPageState();
}

class _QuizListPageState extends State<QuizListPage> {
  final QuizService service = QuizService();

  List<Quiz> filteredQuizzes = [];
  List<Quiz> quizzes = [];

  bool loading = true;

  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadQuizzes();
  }

  Future<void> loadQuizzes() async {
    setState(() => loading = true);

    quizzes = await service.getQuizzes(widget.course.id);
    filteredQuizzes = List.from(quizzes);

    if (!mounted) return;

    setState(() => loading = false);
  }

  Future<void> deleteQuiz(String id) async {
    await service.deleteQuiz(id);
    await loadQuizzes();
  }

  void searchQuiz(String value) {
    setState(() {
      filteredQuizzes = quizzes.where((quiz) {
        return quiz.title.toLowerCase().contains(value.toLowerCase());
      }).toList();
    });
  }

  Future<void> confirmDelete(Quiz quiz) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Quiz"),
        content: Text(
          "Are you sure you want to delete '${quiz.title}'?\n\nThis action cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await deleteQuiz(quiz.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Quiz deleted successfully."),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF8FAFF), Color(0xFFEEF4FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: loading
              ? const Center(child: CircularProgressIndicator())
              : quizzes.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.quiz_outlined,
                                    size: 70, color: theme.colorScheme.primary),
                                const SizedBox(height: 12),
                                const Text('No quizzes yet',
                                    style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                const Text(
                                    'Create your first quiz using the button below.',
                                    textAlign: TextAlign.center),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                  : CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF2563EB),
                                    Color(0xFF3B82F6)
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.course.title,
                                    style: theme.textTheme.titleLarge?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 6),
                                  const Text(
                                      'Build assessments that feel polished and engaging.',
                                      style: TextStyle(color: Colors.white70)),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                            child: TextField(
                              controller: searchController,
                              onChanged: searchQuiz,
                              decoration: const InputDecoration(
                                hintText: 'Search quizzes...',
                                prefixIcon: Icon(Icons.search),
                              ),
                            ),
                          ),
                        ),
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final quiz = filteredQuizzes[index];
                              return Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(20, 0, 20, 12),
                                child: Card(
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.all(16),
                                    title: Text(quiz.title),
                                    subtitle: Text(quiz.description),
                                    leading: CircleAvatar(
                                      backgroundColor: theme.colorScheme.primary
                                          .withOpacity(0.12),
                                      child: Icon(Icons.quiz_rounded,
                                          color: theme.colorScheme.primary),
                                    ),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              QuestionListPage(quiz: quiz),
                                        ),
                                      );
                                    },
                                    trailing: PopupMenuButton<String>(
                                      onSelected: (value) async {
                                        if (value == 'edit') {
                                          final updated = await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (_) =>
                                                    EditQuizPage(quiz: quiz)),
                                          );
                                          if (updated == true) {
                                            loadQuizzes();
                                          }
                                        } else if (value == 'results') {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (_) => QuizResultsPage(
                                                    quiz: quiz)),
                                          );
                                        } else if (value == 'delete') {
                                          confirmDelete(quiz);
                                        }
                                      },
                                      itemBuilder: (context) => const [
                                        PopupMenuItem(
                                            value: 'edit', child: Text('Edit')),
                                        PopupMenuItem(
                                            value: 'results',
                                            child: Text('Results')),
                                        PopupMenuItem(
                                            value: 'delete',
                                            child: Text('Delete')),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                            childCount: filteredQuizzes.length,
                          ),
                        ),
                      ],
                    ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final created = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CreateQuizPage(course: widget.course),
            ),
          );

          if (created == true) {
            loadQuizzes();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('New Quiz'),
      ),
    );
  }
}

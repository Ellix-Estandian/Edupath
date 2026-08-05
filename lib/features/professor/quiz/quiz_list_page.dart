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

  List<Quiz> quizzes = [];

  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadQuizzes();
  }

  Future<void> loadQuizzes() async {
    setState(() => loading = true);

    quizzes = await service.getQuizzes(widget.course.id);

    if (!mounted) return;

    setState(() => loading = false);
  }

  Future<void> deleteQuiz(String id) async {
    await service.deleteQuiz(id);
    await loadQuizzes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.course.title} Quiz"),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          final created = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CreateQuizPage(
                course: widget.course,
              ),
            ),
          );

          if (created == true) {
            loadQuizzes();
          }
        },
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : quizzes.isEmpty
              ? const Center(
                  child: Text("No quizzes yet"),
                )
              : ListView.builder(
                  itemCount: quizzes.length,
                  itemBuilder: (_, index) {
                    final quiz = quizzes[index];

                    return Card(
                        margin: const EdgeInsets.all(10),
                        child: ListTile(
                          title: Text(quiz.title),
                          subtitle: Text(quiz.description),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => QuestionListPage(
                                  quiz: quiz,
                                ),
                              ),
                            );
                          },
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                tooltip: "Edit",
                                onPressed: () async {
                                  final updated = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => EditQuizPage(
                                        quiz: quiz,
                                      ),
                                    ),
                                  );

                                  if (updated == true) {
                                    loadQuizzes();
                                  }
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.bar_chart),
                                tooltip: "Results",
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => QuizResultsPage(
                                        quiz: quiz,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                tooltip: "Delete",
                                onPressed: () {
                                  deleteQuiz(quiz.id);
                                },
                              ),
                            ],
                          ),
                        ));
                  },
                ),
    );
  }
}

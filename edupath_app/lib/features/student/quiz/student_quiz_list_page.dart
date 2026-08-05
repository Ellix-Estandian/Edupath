import 'package:flutter/material.dart';

import '../../../core/services/quiz_service.dart';
import '../../../models/course.dart';
import '../../../models/quiz.dart';
import 'take_quiz_page.dart';

class StudentQuizListPage extends StatefulWidget {
  final Course course;

  const StudentQuizListPage({
    super.key,
    required this.course,
  });

  @override
  State<StudentQuizListPage> createState() => _StudentQuizListPageState();
}

class _StudentQuizListPageState extends State<StudentQuizListPage> {
  final QuizService service = QuizService();

  List<Quiz> quizzes = [];

  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadQuizzes();
  }

  Future<void> loadQuizzes() async {
    quizzes = await service.getQuizzes(widget.course.id);

    if (!mounted) return;

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quizzes"),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : quizzes.isEmpty
              ? const Center(
                  child: Text("No quizzes available."),
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
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => TakeQuizPage(
                                quiz: quiz,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../core/services/quiz_service.dart';
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
    setState(() {
      loading = true;
    });

    answers = await _quizService.getAnswers(widget.question.id);

    if (!mounted) return;

    setState(() {
      loading = false;
    });
  }

  Future<void> deleteAnswer(String id) async {
    await _quizService.deleteAnswer(id);
    loadAnswers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Answer Choices"),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          final created = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CreateAnswerPage(
                question: widget.question,
              ),
            ),
          );

          if (created == true) {
            loadAnswers();
          }
        },
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : answers.isEmpty
              ? const Center(
                  child: Text("No answer choices yet"),
                )
              : ListView.builder(
                  itemCount: answers.length,
                  itemBuilder: (context, index) {
                    final answer = answers[index];

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: ListTile(
                        leading: Icon(
                          answer.isCorrect
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          color: answer.isCorrect ? Colors.green : Colors.grey,
                        ),
                        title: Text(answer.answer),
                        subtitle: Text(
                          answer.isCorrect
                              ? "Correct Answer"
                              : "Incorrect Answer",
                        ),
                        onTap: () async {
                          final updated = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditAnswerPage(
                                answer: answer,
                              ),
                            ),
                          );

                          if (updated == true) {
                            loadAnswers();
                          }
                        },
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            deleteAnswer(answer.id);
                          },
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

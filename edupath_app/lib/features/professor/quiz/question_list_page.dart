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

  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadQuestions();
  }

  Future<void> loadQuestions() async {
    setState(() => loading = true);

    questions = await service.getQuestions(widget.quiz.id);

    if (!mounted) return;

    setState(() => loading = false);
  }

  Future<void> deleteQuestion(String id) async {
    await service.deleteQuestion(id);
    await loadQuestions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.quiz.title),
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
            loadQuestions();
          }
        },
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : questions.isEmpty
              ? const Center(
                  child: Text("No questions yet"),
                )
              : ListView.builder(
                  itemCount: questions.length,
                  itemBuilder: (_, index) {
                    final question = questions[index];

                    return Card(
                      margin: const EdgeInsets.all(10),
                      child: ListTile(
                        title: Text(question.question),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AnswerListPage(
                                question: question,
                              ),
                            ),
                          );
                        },
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () async {
                                final updated = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => EditQuestionPage(
                                      question: question,
                                    ),
                                  ),
                                );

                                if (updated == true) {
                                  loadQuestions();
                                }
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                deleteQuestion(question.id);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

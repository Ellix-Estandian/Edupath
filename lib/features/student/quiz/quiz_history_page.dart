import 'package:flutter/material.dart';

import '../../../core/services/quiz_service.dart';

class QuizHistoryPage extends StatefulWidget {
  const QuizHistoryPage({super.key});

  @override
  State<QuizHistoryPage> createState() => _QuizHistoryPageState();
}

class _QuizHistoryPageState extends State<QuizHistoryPage> {
  final QuizService service = QuizService();

  List<Map<String, dynamic>> history = [];

  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  Future<void> loadHistory() async {
    history = await service.getStudentQuizHistory();

    if (!mounted) return;

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quiz History"),
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : history.isEmpty
              ? const Center(
                  child: Text("No quiz attempts yet."),
                )
              : ListView.builder(
                  itemCount: history.length,
                  itemBuilder: (_, index) {
                    final item = history[index];
                    final quiz = item["quizzes"];

                    final score = item["score"] as int;
                    final total = item["total_items"] as int;
                    final percentage =
                        total == 0 ? 0 : ((score / total) * 100).round();

                    return Card(
                      margin: const EdgeInsets.all(10),
                      child: ListTile(
                        leading: const Icon(Icons.history),
                        title: Text(quiz["title"]),
                        subtitle: Text("$score / $total"),
                        trailing: Text("$percentage%"),
                      ),
                    );
                  },
                ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../core/services/quiz_service.dart';
import '../../../models/quiz.dart';

class QuizResultsPage extends StatefulWidget {
  final Quiz quiz;

  const QuizResultsPage({
    super.key,
    required this.quiz,
  });

  @override
  State<QuizResultsPage> createState() => _QuizResultsPageState();
}

class _QuizResultsPageState extends State<QuizResultsPage> {
  final QuizService service = QuizService();

  List<Map<String, dynamic>> results = [];

  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadResults();
  }

  Future<void> loadResults() async {
    results = await service.getQuizResults(widget.quiz.id);

    if (!mounted) return;

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.quiz.title} Results"),
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : results.isEmpty
              ? const Center(
                  child: Text("No submissions yet."),
                )
              : ListView.builder(
                  itemCount: results.length,
                  itemBuilder: (_, index) {
                    final result = results[index];
                    final profile = result["profiles"];

                    return Card(
                      margin: const EdgeInsets.all(10),
                      child: ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.person),
                        ),
                        title: Text(
                          profile["full_name"] ?? profile["email"],
                        ),
                        subtitle: Text(
                          "${result["score"]} / ${result["total_items"]}",
                        ),
                        trailing: Text(
                          "${((result["score"] / result["total_items"]) * 100).round()}%",
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

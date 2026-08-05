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

  double averageScore = 0;
  int highestScore = 0;
  int lowestScore = 0;
  int totalAttempts = 0;

  List<Map<String, dynamic>> results = [];

  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadResults();
  }

  Future<void> loadResults() async {
    results = await service.getQuizResults(widget.quiz.id);

    totalAttempts = results.length;

    if (results.isNotEmpty) {
      int total = 0;

      highestScore = results.first["score"];
      lowestScore = results.first["score"];

      for (final result in results) {
        final score = result["score"] as int;

        total += score;

        if (score > highestScore) {
          highestScore = score;
        }

        if (score < lowestScore) {
          lowestScore = score;
        }
      }

      averageScore = total / totalAttempts;
    }

    if (!mounted) return;

    setState(() {
      loading = false;
    });
  }

  Widget summaryCard(
    String title,
    String value,
    IconData icon,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(title),
          ],
        ),
      ),
    );
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
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Expanded(
                            child: summaryCard(
                              "Attempts",
                              totalAttempts.toString(),
                              Icons.assignment,
                            ),
                          ),
                          Expanded(
                            child: summaryCard(
                              "Average",
                              averageScore > 0
                                  ? "${averageScore.round()}%"
                                  : "0%",
                              Icons.percent,
                            ),
                          ),
                          Expanded(
                            child: summaryCard(
                              "Highest",
                              highestScore.toString(),
                              Icons.trending_up,
                            ),
                          ),
                          Expanded(
                            child: summaryCard(
                              "Lowest",
                              lowestScore.toString(),
                              Icons.trending_down,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                        child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          childAspectRatio: 1.4,
                          children: [
                            summaryCard(
                              "Average",
                              averageScore.toStringAsFixed(1),
                              Icons.bar_chart,
                            ),
                            summaryCard(
                              "Highest",
                              "$highestScore",
                              Icons.emoji_events,
                            ),
                            summaryCard(
                              "Lowest",
                              "$lowestScore",
                              Icons.trending_down,
                            ),
                            summaryCard(
                              "Attempts",
                              "$totalAttempts",
                              Icons.people,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "Student Results",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ...results.map((result) {
                          final profile = result["profiles"];

                          return Card(
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
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    )),
                  ],
                ),
    );
  }
}

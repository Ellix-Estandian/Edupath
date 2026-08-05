import 'package:flutter/material.dart';

class QuizResultPage extends StatelessWidget {
  final int score;
  final int total;

  const QuizResultPage({
    super.key,
    required this.score,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = total == 0 ? 0 : (score / total * 100).round();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Quiz Result"),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(24),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.emoji_events,
                  size: 70,
                  color: Colors.amber,
                ),
                const SizedBox(height: 20),
                Text(
                  "$score / $total",
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "$percentage%",
                  style: const TextStyle(
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    Navigator.popUntil(
                      context,
                      (route) => route.isFirst,
                    );
                  },
                  child: const Text("Finish"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

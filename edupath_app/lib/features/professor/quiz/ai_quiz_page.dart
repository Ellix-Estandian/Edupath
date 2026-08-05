import 'package:flutter/material.dart';

import '../../../core/services/ai_quiz_service.dart';
import '../../../models/course.dart';

class AIQuizPage extends StatefulWidget {
  final Course course;

  const AIQuizPage({
    super.key,
    required this.course,
  });

  @override
  State<AIQuizPage> createState() => _AIQuizPageState();
}

class _AIQuizPageState extends State<AIQuizPage> {
  final AIQuizService service = AIQuizService();

  final topicController = TextEditingController();

  bool loading = false;

  List<dynamic> questions = [];

  Future<void> generate() async {
    if (topicController.text.trim().isEmpty) return;

    setState(() => loading = true);

    try {
      final result = await service.generateQuiz(
        courseId: widget.course.id,
        topic: topicController.text.trim(),
      );

      setState(() {
        questions = result;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }

    setState(() => loading = false);
  }

  Future<void> saveQuiz() async {
    if (questions.isEmpty) return;

    try {
      await service.saveQuiz(
        courseId: widget.course.id,
        title: topicController.text.trim(),
        questions: questions,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Quiz saved successfully!"),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Quiz Generator"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: topicController,
              decoration: const InputDecoration(
                labelText: "Topic",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: loading ? null : generate,
              child: const Text("Generate Quiz"),
            ),
            if (questions.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text("Save Quiz"),
                  onPressed: saveQuiz,
                ),
              ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: questions.length,
                itemBuilder: (_, index) {
                  final q = questions[index];
                  return Card(
                    child: ListTile(
                      title: Text(q["question"]),
                      subtitle: Text(
                        "Answer: ${q["answer"]}",
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

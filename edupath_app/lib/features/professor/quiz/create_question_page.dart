import 'package:flutter/material.dart';

import '../../../core/services/quiz_service.dart';
import '../../../models/quiz.dart';

class CreateQuestionPage extends StatefulWidget {
  final Quiz quiz;

  const CreateQuestionPage({
    super.key,
    required this.quiz,
  });

  @override
  State<CreateQuestionPage> createState() => _CreateQuestionPageState();
}

class _CreateQuestionPageState extends State<CreateQuestionPage> {
  final QuizService service = QuizService();

  final controller = TextEditingController();

  bool loading = false;

  Future<void> saveQuestion() async {
    if (controller.text.trim().isEmpty) return;

    setState(() => loading = true);

    await service.createQuestion(
      quizId: widget.quiz.id,
      question: controller.text.trim(),
    );

    if (!mounted) return;

    Navigator.pop(context, true);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Question"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: controller,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: "Question",
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : saveQuestion,
                child: loading
                    ? const CircularProgressIndicator()
                    : const Text("Save Question"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

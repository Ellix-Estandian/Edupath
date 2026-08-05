import 'package:flutter/material.dart';

import '../../../core/services/quiz_service.dart';
import '../../../models/quiz_question.dart';

class CreateAnswerPage extends StatefulWidget {
  final QuizQuestion question;

  const CreateAnswerPage({
    super.key,
    required this.question,
  });

  @override
  State<CreateAnswerPage> createState() => _CreateAnswerPageState();
}

class _CreateAnswerPageState extends State<CreateAnswerPage> {
  final QuizService service = QuizService();

  final answerController = TextEditingController();

  bool isCorrect = false;
  bool loading = false;

  Future<void> saveAnswer() async {
    if (answerController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Answer cannot be empty"),
        ),
      );
      return;
    }

    setState(() {
      loading = true;
    });

    await service.createAnswer(
      questionId: widget.question.id,
      answer: answerController.text.trim(),
      isCorrect: isCorrect,
    );

    if (!mounted) return;

    Navigator.pop(context, true);
  }

  @override
  void dispose() {
    answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Answer"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: answerController,
              decoration: const InputDecoration(
                labelText: "Answer Choice",
              ),
            ),
            const SizedBox(height: 20),
            SwitchListTile(
              title: const Text("Correct Answer"),
              value: isCorrect,
              onChanged: (value) {
                setState(() {
                  isCorrect = value;
                });
              },
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : saveAnswer,
                child: loading
                    ? const CircularProgressIndicator()
                    : const Text("Save Answer"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../core/services/quiz_service.dart';
import '../../../models/quiz_answer.dart';

class EditAnswerPage extends StatefulWidget {
  final QuizAnswer answer;

  const EditAnswerPage({
    super.key,
    required this.answer,
  });

  @override
  State<EditAnswerPage> createState() => _EditAnswerPageState();
}

class _EditAnswerPageState extends State<EditAnswerPage> {
  final QuizService service = QuizService();

  late final TextEditingController answerController;

  bool isCorrect = false;
  bool loading = false;

  @override
  void initState() {
    super.initState();

    answerController = TextEditingController(
      text: widget.answer.answer,
    );

    isCorrect = widget.answer.isCorrect;
  }

  Future<void> updateAnswer() async {
    if (answerController.text.trim().isEmpty) return;

    setState(() {
      loading = true;
    });

    await service.updateAnswer(
      id: widget.answer.id,
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
        title: const Text("Edit Answer"),
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
                onPressed: loading ? null : updateAnswer,
                child: loading
                    ? const CircularProgressIndicator()
                    : const Text("Save Changes"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

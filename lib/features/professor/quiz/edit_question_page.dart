import 'package:flutter/material.dart';

import '../../../core/services/quiz_service.dart';
import '../../../models/quiz_question.dart';

class EditQuestionPage extends StatefulWidget {
  final QuizQuestion question;

  const EditQuestionPage({
    super.key,
    required this.question,
  });

  @override
  State<EditQuestionPage> createState() => _EditQuestionPageState();
}

class _EditQuestionPageState extends State<EditQuestionPage> {
  final QuizService service = QuizService();

  late final TextEditingController controller;

  bool loading = false;

  @override
  void initState() {
    super.initState();

    controller = TextEditingController(
      text: widget.question.question,
    );
  }

  Future<void> updateQuestion() async {
    if (controller.text.trim().isEmpty) return;

    setState(() {
      loading = true;
    });

    await service.updateQuestion(
      id: widget.question.id,
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
        title: const Text("Edit Question"),
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
                onPressed: loading ? null : updateQuestion,
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

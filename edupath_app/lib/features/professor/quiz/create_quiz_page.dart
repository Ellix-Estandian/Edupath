import 'package:flutter/material.dart';

import '../../../core/services/quiz_service.dart';
import '../../../models/course.dart';

class CreateQuizPage extends StatefulWidget {
  final Course course;

  const CreateQuizPage({
    super.key,
    required this.course,
  });

  @override
  State<CreateQuizPage> createState() => _CreateQuizPageState();
}

class _CreateQuizPageState extends State<CreateQuizPage> {
  final QuizService service = QuizService();

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

  bool loading = false;

  Future<void> saveQuiz() async {
    if (titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Quiz title is required"),
        ),
      );
      return;
    }

    setState(() {
      loading = true;
    });

    await service.createQuiz(
      courseId: widget.course.id,
      title: titleController.text.trim(),
      description: descriptionController.text.trim(),
    );

    if (!mounted) return;

    Navigator.pop(context, true);
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Quiz"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: "Quiz Title",
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "Description",
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : saveQuiz,
                child: loading
                    ? const CircularProgressIndicator()
                    : const Text("Create Quiz"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

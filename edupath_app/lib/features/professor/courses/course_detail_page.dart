import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';

import '../../../core/services/presentation_service.dart';
import '../../../models/course.dart';
import '../learning_materials/learning_materials_page.dart';
import '../quiz/ai_quiz_page.dart';
import '../quiz/quiz_list_page.dart';
import '../exam/ai_exam_page.dart';

class CourseDetailPage extends StatefulWidget {
  final Course course;

  const CourseDetailPage({
    super.key,
    required this.course,
  });

  @override
  State<CourseDetailPage> createState() => _CourseDetailPageState();
}

class _CourseDetailPageState extends State<CourseDetailPage> {
  final PresentationService presentationService = PresentationService();

  Future<void> generatePresentation() async {
    final controller = TextEditingController();

    final topic = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Generate Presentation"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: "Enter topic",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(
                context,
                controller.text.trim(),
              );
            },
            child: const Text("Generate"),
          ),
        ],
      ),
    );

    if (topic == null || topic.isEmpty) {
      return;
    }

    // Show loading indicator while waiting for the AI backend.
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final file = await presentationService.generatePresentation(
        courseId: widget.course.id,
        topic: topic,
      );

      if (mounted) Navigator.pop(context);

      await OpenFilex.open(file.path);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Presentation generated successfully."),
          ),
        );
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: $e"),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.course.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.course.title,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              widget.course.description,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.upload_file),
              title: const Text("Learning Materials"),
              subtitle: const Text("Upload PDFs, DOCX, TXT"),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LearningMaterialsPage(
                      course: widget.course,
                    ),
                  ),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.quiz),
              title: const Text("Quizzes"),
              subtitle: const Text("Create and manage quizzes"),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => QuizListPage(
                      course: widget.course,
                    ),
                  ),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.auto_awesome),
              title: const Text("AI Quiz Generator"),
              subtitle: const Text("Generate quizzes from learning materials"),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AIQuizPage(
                      course: widget.course,
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.slideshow),
              title: const Text("Generate Presentation"),
              subtitle: const Text("Create AI PowerPoint slides"),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: generatePresentation,
            ),
            ListTile(
              leading: const Icon(Icons.description),
              title: const Text("AI Examination"),
              subtitle: const Text("Generate a complete examination"),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AIExamPage(
                      course: widget.course,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            Card(
              child: ListTile(
                leading: const Icon(Icons.key),
                title: const Text("Course Code"),
                subtitle: SelectableText(widget.course.courseCode),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

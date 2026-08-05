import 'package:flutter/material.dart';

import '../../../core/services/course_service.dart';

class JoinCoursePage extends StatefulWidget {
  const JoinCoursePage({super.key});

  @override
  State<JoinCoursePage> createState() => _JoinCoursePageState();
}

class _JoinCoursePageState extends State<JoinCoursePage> {
  final CourseService _courseService = CourseService();

  final TextEditingController codeController = TextEditingController();

  bool loading = false;

  Future<void> joinCourse() async {
    if (codeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a course code."),
        ),
      );
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      await _courseService.joinCourse(
        codeController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Successfully joined the course."),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }

    if (!mounted) return;

    setState(() {
      loading = false;
    });
  }

  @override
  void dispose() {
    codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Join Course"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: codeController,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                labelText: "Course Code",
                hintText: "Example: AB3K9Q",
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : joinCourse,
                child: loading
                    ? const CircularProgressIndicator()
                    : const Text("Join Course"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

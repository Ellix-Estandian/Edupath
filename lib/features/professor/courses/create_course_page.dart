import 'package:flutter/material.dart';

import '../../../core/services/course_service.dart';

class CreateCoursePage extends StatefulWidget {
  const CreateCoursePage({super.key});

  @override
  State<CreateCoursePage> createState() => _CreateCoursePageState();
}

class _CreateCoursePageState extends State<CreateCoursePage> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  final CourseService _courseService = CourseService();

  bool loading = false;

  Future<void> saveCourse() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Course title is required."),
        ),
      );
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      await _courseService.createCourse(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
      );

      if (!mounted) return;

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }

    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Course"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: "Course Title",
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: "Description",
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : saveCourse,
                child: loading
                    ? const CircularProgressIndicator()
                    : const Text("Create Course"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

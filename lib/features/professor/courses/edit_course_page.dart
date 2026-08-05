import 'package:flutter/material.dart';

import '../../../core/services/course_service.dart';
import '../../../models/course.dart';

class EditCoursePage extends StatefulWidget {
  final Course course;

  const EditCoursePage({
    super.key,
    required this.course,
  });

  @override
  State<EditCoursePage> createState() => _EditCoursePageState();
}

class _EditCoursePageState extends State<EditCoursePage> {
  final CourseService _courseService = CourseService();

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  bool loading = false;

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(
      text: widget.course.title,
    );

    _descriptionController = TextEditingController(
      text: widget.course.description,
    );
  }

  Future<void> updateCourse() async {
    setState(() {
      loading = true;
    });

    try {
      await _courseService.updateCourse(
        id: widget.course.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
      );

      if (!mounted) return;

      Navigator.pop(context, true);
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
        title: const Text("Edit Course"),
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
                onPressed: loading ? null : updateCourse,
                child: loading
                    ? const CircularProgressIndicator()
                    : const Text("Save Changes"),
              ),
            )
          ],
        ),
      ),
    );
  }
}

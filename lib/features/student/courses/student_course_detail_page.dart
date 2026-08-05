import 'package:flutter/material.dart';

import '../../../models/course.dart';
import '../quiz/student_quiz_list_page.dart';
import '../materials/student_learning_materials_page.dart';

class StudentCourseDetailPage extends StatelessWidget {
  final Course course;

  const StudentCourseDetailPage({
    super.key,
    required this.course,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(course.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              course.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(course.description),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: const Icon(Icons.menu_book),
              label: const Text("Learning Materials"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => StudentLearningMaterialsPage(
                      course: course,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 15),
            ElevatedButton.icon(
              icon: const Icon(Icons.quiz),
              label: const Text("Take Quiz"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => StudentQuizListPage(
                      course: course,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

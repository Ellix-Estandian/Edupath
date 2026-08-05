import 'package:flutter/material.dart';

import '../../../models/course.dart';
import '../learning_materials/learning_materials_page.dart';
import '../quiz/quiz_list_page.dart';

class CourseDetailPage extends StatelessWidget {
  final Course course;

  const CourseDetailPage({
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              course.title,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              course.description,
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
                      course: course,
                    ),
                  ),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.quiz),
              title: const Text("AI Quizzes"),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {},
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.assignment),
              title: const Text("AI Examinations"),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {},
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.quiz),
              label: const Text("Manage Quiz"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => QuizListPage(
                      course: course,
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
                subtitle: SelectableText(course.courseCode),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

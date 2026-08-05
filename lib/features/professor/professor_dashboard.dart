import 'package:flutter/material.dart';
import 'courses/courses_page.dart';

class ProfessorDashboard extends StatelessWidget {
  const ProfessorDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Professor Dashboard"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CoursesPage(),
                  ),
                );
              },
              child: const Text("My Courses"),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../core/services/dashboard_service.dart';
import 'courses/courses_page.dart';

class ProfessorDashboard extends StatefulWidget {
  const ProfessorDashboard({super.key});

  @override
  State<ProfessorDashboard> createState() => _ProfessorDashboardState();
}

class _ProfessorDashboardState extends State<ProfessorDashboard> {
  final DashboardService service = DashboardService();

  bool loading = true;

  Map<String, int> stats = {
    "courses": 0,
    "students": 0,
    "quizzes": 0,
    "materials": 0,
  };

  @override
  void initState() {
    super.initState();
    loadStats();
  }

  Future<void> loadStats() async {
    stats = await service.getProfessorStats();

    if (!mounted) return;

    setState(() {
      loading = false;
    });
  }

  Widget statCard(String title, int value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(icon, size: 40),
            const SizedBox(height: 10),
            Text(
              "$value",
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(title),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Professor Dashboard"),
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 1.3,
                    children: [
                      statCard(
                        "Courses",
                        stats["courses"]!,
                        Icons.class_,
                      ),
                      statCard(
                        "Students",
                        stats["students"]!,
                        Icons.people,
                      ),
                      statCard(
                        "Quizzes",
                        stats["quizzes"]!,
                        Icons.quiz,
                      ),
                      statCard(
                        "Materials",
                        stats["materials"]!,
                        Icons.folder,
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.school),
                      label: const Text("My Courses"),
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CoursesPage(),
                          ),
                        );

                        loadStats();
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

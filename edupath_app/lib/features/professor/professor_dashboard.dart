import 'package:flutter/material.dart';

import '../../core/services/dashboard_service.dart';
import 'courses/courses_page.dart';
import 'package:fl_chart/fl_chart.dart';
import '../notifications/notification_page.dart';

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

  double averageScore = 0;

  List<Map<String, dynamic>> recentAttempts = [];
  List<Map<String, dynamic>> quizPerformance = [];

  @override
  void initState() {
    super.initState();
    loadStats();
  }

  Future<void> loadStats() async {
    loading = true;

    if (mounted) {
      setState(() {});
    }

    stats = await service.getProfessorStats();

    averageScore = await service.getAverageQuizScore();

    recentAttempts = await service.getRecentQuizAttempts();

    quizPerformance = await service.getQuizPerformance();

    if (!mounted) return;

    setState(() {
      loading = false;
    });
  }

  Widget statCard(
    String title,
    int value,
    IconData icon,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40),
            const SizedBox(height: 10),
            Text(
              value.toString(),
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
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
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const NotificationsPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: loadStats,
              child: ListView(
                padding: const EdgeInsets.all(16),
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
                  const SizedBox(height: 20),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.bar_chart),
                      title: const Text("Average Quiz Score"),
                      trailing: Text(
                        "${averageScore.toStringAsFixed(1)}%",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Quiz Performance",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            height: 250,
                            child: BarChart(
                              BarChartData(
                                alignment: BarChartAlignment.spaceAround,
                                titlesData: FlTitlesData(
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: true),
                                  ),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (value, meta) {
                                        if (value.toInt() >=
                                            quizPerformance.length) {
                                          return const SizedBox();
                                        }

                                        return Padding(
                                          padding:
                                              const EdgeInsets.only(top: 8),
                                          child: Text(
                                            "${value.toInt() + 1}",
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                barGroups: List.generate(
                                  quizPerformance.length,
                                  (index) => BarChartGroupData(
                                    x: index,
                                    barRods: [
                                      BarChartRodData(
                                        toY: quizPerformance[index]["average"],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  const Text(
                    "Recent Quiz Activity",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (recentAttempts.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Center(
                          child: Text(
                            "No quiz attempts yet.",
                          ),
                        ),
                      ),
                    )
                  else
                    ...recentAttempts.map(
                      (attempt) => Card(
                        child: ListTile(
                          leading: const CircleAvatar(
                            child: Icon(Icons.person),
                          ),
                          title: Text(
                            attempt["student"],
                          ),
                          subtitle: Text(
                            attempt["quiz"],
                          ),
                          trailing: Text(
                            attempt["score"],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 25),
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

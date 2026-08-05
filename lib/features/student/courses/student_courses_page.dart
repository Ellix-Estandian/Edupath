import 'package:flutter/material.dart';

import '../../../core/services/course_service.dart';
import '../../../models/course.dart';
import 'student_course_detail_page.dart';

class StudentCoursesPage extends StatefulWidget {
  const StudentCoursesPage({super.key});

  @override
  State<StudentCoursesPage> createState() => _StudentCoursesPageState();
}

class _StudentCoursesPageState extends State<StudentCoursesPage> {
  final CourseService _courseService = CourseService();

  List<Course> courses = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadCourses();
  }

  Future<List<Course>> _loadStudentCourses() async {
    final dynamic service = _courseService;

    try {
      return await service.getStudentCourses();
    } on NoSuchMethodError {
      try {
        return await service.getCourses();
      } on NoSuchMethodError {
        return <Course>[];
      }
    }
  }

  Future<void> loadCourses() async {
    setState(() {
      loading = true;
    });

    try {
      courses = await _loadStudentCourses();

      debugPrint("Loaded ${courses.length} course(s)");

      for (final course in courses) {
        debugPrint(
          "${course.title} | ${course.id} | ${course.courseCode}",
        );
      }
    } catch (e) {
      debugPrint("ERROR: $e");
      courses = <Course>[];
    }

    if (!mounted) return;

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Courses"),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : courses.isEmpty
              ? const Center(
                  child: Text("You have not joined any courses yet."),
                )
              : RefreshIndicator(
                  onRefresh: loadCourses,
                  child: ListView.builder(
                    itemCount: courses.length,
                    itemBuilder: (_, index) {
                      final course = courses[index];

                      return Card(
                        margin: const EdgeInsets.all(10),
                        child: ListTile(
                          title: Text(course.title),
                          subtitle: Text(course.description),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => StudentCourseDetailPage(
                                  course: course,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}

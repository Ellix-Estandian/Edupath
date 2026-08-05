import 'package:flutter/material.dart';

import '../../../core/services/course_service.dart';
import '../../../models/course.dart';
import 'create_course_page.dart';
import 'edit_course_page.dart';
import 'course_detail_page.dart';

class CoursesPage extends StatefulWidget {
  const CoursesPage({super.key});

  @override
  State<CoursesPage> createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage> {
  final CourseService _courseService = CourseService();

  List<Course> courses = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadCourses();
  }

  Future<void> loadCourses() async {
    setState(() {
      loading = true;
    });

    courses = await _courseService.getProfessorCourses();

    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> deleteCourse(String id) async {
    await _courseService.deleteCourse(id);
    await loadCourses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Courses"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CreateCoursePage(),
            ),
          ).then((_) => loadCourses());
        },
        child: const Icon(Icons.add),
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : courses.isEmpty
              ? const Center(
                  child: Text("No courses yet"),
                )
              : ListView.builder(
                  itemCount: courses.length,
                  itemBuilder: (context, index) {
                    final course = courses[index];

                    return ListTile(
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CourseDetailPage(
                              course: course,
                            ),
                          ),
                        );
                        loadCourses();
                      },
                      title: Text(course.title),
                      subtitle: Text(course.description),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () async {
                              final updated = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => EditCoursePage(
                                    course: course,
                                  ),
                                ),
                              );

                              if (updated == true) {
                                loadCourses();
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              deleteCourse(course.id);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}

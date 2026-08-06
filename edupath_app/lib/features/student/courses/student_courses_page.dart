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
  List<Course> filtered = [];
  final TextEditingController searchController = TextEditingController();

  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadCourses();
    searchController.addListener(_applyFilter);
  }

  void _applyFilter() {
    final q = searchController.text.trim().toLowerCase();
    if (q.isEmpty) {
      setState(() => filtered = List.from(courses));
      return;
    }

    setState(() {
      filtered = courses
          .where((c) =>
              (c.title ?? '').toLowerCase().contains(q) ||
              (c.courseCode ?? '').toLowerCase().contains(q))
          .toList();
    });
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

  String? lastLoadDebug;

  Future<void> loadCourses() async {
    setState(() {
      loading = true;
      lastLoadDebug = null;
    });

    try {
      courses = await _loadStudentCourses();

      debugPrint("Loaded ${courses.length} course(s)");

      for (final course in courses) {
        debugPrint("${course.title} | ${course.id} | ${course.courseCode}");
      }

      // If we unexpectedly have no courses, gather diagnostics
      if (courses.isEmpty) {
        try {
          final enrollments = await _courseService.getStudentEnrollmentsRaw();
          final allCourses = await _courseService.getAllCourses();

          lastLoadDebug =
              'enrollments=${enrollments.length}; allCourses=${allCourses.length}; enrollmentsPreview=${enrollments.isNotEmpty ? enrollments.take(5).toList() : []}';
          debugPrint('StudentCourses diagnostics: $lastLoadDebug');
        } catch (diagErr) {
          lastLoadDebug = 'diagnostics failed: $diagErr';
          debugPrint('Diagnostics error: $diagErr');
        }
      }
    } catch (e) {
      debugPrint("ERROR: $e");
      courses = <Course>[];
      lastLoadDebug = e.toString();
    }

    if (!mounted) return;

    setState(() {
      loading = false;
      filtered = List.from(courses);
    });
  }

  Widget _buildContent() {
    final theme = Theme.of(context);
    try {
      if (loading) {
        return const Center(child: CircularProgressIndicator());
      }

      // Simpler list-based layout to avoid Sliver and constraint cascade issues.
      final List<Widget> items = [];

      // Header card
      items.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.primary.withOpacity(0.9)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.16),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child:
                          const Icon(Icons.school_rounded, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'My Courses',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Jump back in and keep learning without losing momentum.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      );

      // Search
      items.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Search courses or codes',
                  border: InputBorder.none,
                  icon: const Icon(Icons.search),
                  suffixIcon: searchController.text.isNotEmpty
                      ? IconButton(
                          onPressed: () => searchController.clear(),
                          icon: const Icon(Icons.clear))
                      : null,
                ),
              ),
            ),
          ),
        ),
      );

      // Debug banner
      items.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceVariant.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                      'Debug: loaded ${courses.length} courses • filtered ${filtered.length}',
                      style: theme.textTheme.bodySmall),
                ),
              ),
            ],
          ),
        ),
      );

      if (filtered.isEmpty) {
        items.add(
          Padding(
            padding: const EdgeInsets.all(20),
            child: Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.school_outlined,
                        size: 60, color: theme.colorScheme.primary),
                    const SizedBox(height: 12),
                    Text('No courses found',
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    Text('Try joining a course or clear your search.',
                        style: theme.textTheme.bodySmall,
                        textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    if (lastLoadDebug != null) ...[
                      const SizedBox(height: 12),
                      SelectableText('Debug: $lastLoadDebug',
                          style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant)),
                      const SizedBox(height: 8),
                    ],
                    if (lastLoadDebug != null &&
                        lastLoadDebug!.contains('currentUser is null')) ...[
                      Text(
                          'You are not signed in. Please sign in to view your enrolled courses.',
                          style: theme.textTheme.bodySmall,
                          textAlign: TextAlign.center),
                      const SizedBox(height: 8),
                      ElevatedButton(
                          onPressed: () async {
                            await Navigator.pushNamed(context, '/login');
                            await loadCourses();
                          },
                          child: const Text('Go to Login')),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      } else {
        for (final course in filtered) {
          items.add(
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              StudentCourseDetailPage(course: course)),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.menu_book_rounded,
                              color: theme.colorScheme.primary),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(course.title,
                                  style: theme.textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w700)),
                              const SizedBox(height: 6),
                              Text(course.description,
                                  style: theme.textTheme.bodySmall
                                      ?.copyWith(color: theme.hintColor),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(course.courseCode,
                                style: theme.textTheme.bodySmall
                                    ?.copyWith(color: theme.hintColor)),
                            const SizedBox(height: 8),
                            Icon(Icons.arrow_forward_ios,
                                size: 16, color: theme.hintColor),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }
      }

      return RefreshIndicator(
        onRefresh: loadCourses,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 100),
          children: items,
        ),
      );
    } catch (e, st) {
      debugPrint('Error building StudentCoursesPage UI: $e\n$st');
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Something went wrong',
                      style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(e.toString(), style: theme.textTheme.bodySmall),
                  const SizedBox(height: 12),
                  ElevatedButton(
                      onPressed: loadCourses, child: const Text('Retry')),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    searchController.removeListener(_applyFilter);
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF8FAFF), Color(0xFFEEF4FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: _buildContent(),
        ),
      ),
    );
  }
}

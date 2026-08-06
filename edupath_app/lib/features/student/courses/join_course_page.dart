import 'package:flutter/material.dart';

import '../../../core/services/course_service.dart';

class JoinCoursePage extends StatefulWidget {
  const JoinCoursePage({super.key});

  @override
  State<JoinCoursePage> createState() => _JoinCoursePageState();
}

class _JoinCoursePageState extends State<JoinCoursePage> {
  final CourseService _courseService = CourseService();
  final TextEditingController codeController = TextEditingController();
  bool loading = false;

  Future<void> joinCourse() async {
    if (codeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a course code.'),
        ),
      );
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      await _courseService.joinCourse(
        codeController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Successfully joined the course.'),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }

    if (!mounted) return;

    setState(() {
      loading = false;
    });
  }

  @override
  void dispose() {
    codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Join Course'),
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        foregroundColor: theme.colorScheme.onBackground,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [theme.colorScheme.background, theme.colorScheme.surface.withOpacity(0.5)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  child: Padding(
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.group_add_rounded, color: theme.colorScheme.primary, size: 36),
                        ),

                        const SizedBox(height: 16),

                        Text('Join a Course', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),

                        const SizedBox(height: 8),

                        Text(
                          'Enter the invite code shared by your instructor to access the class.',
                          style: theme.textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 20),

                        // Input
                        TextField(
                          controller: codeController,
                          textCapitalization: TextCapitalization.characters,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleLarge?.copyWith(letterSpacing: 2.0),
                          decoration: InputDecoration(
                            labelText: 'Course Code',
                            hintText: 'AB3K9Q',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            suffixIcon: IconButton(
                              tooltip: 'Clear',
                              icon: const Icon(Icons.clear),
                              onPressed: () => codeController.clear(),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: loading ? null : () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: loading ? null : joinCourse,
                                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                                child: loading
                                    ? Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: const [
                                          SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                          ),
                                          SizedBox(width: 12),
                                          Text('Joining...'),
                                        ],
                                      )
                                    : const Text('Join Course'),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        TextButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ask your instructor for the invite code.')));
                          },
                          child: const Text('Need help finding the code?'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

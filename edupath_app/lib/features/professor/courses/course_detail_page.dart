import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../models/course.dart';
import '../../../core/services/course_service.dart';
import 'edit_course_page.dart';
import '../exam/ai_exam_page.dart';
import '../learning_materials/learning_materials_page.dart';
import '../quiz/ai_quiz_page.dart';
import '../quiz/quiz_list_page.dart';
import '../presentations/presentations_page.dart';
import 'package:flutter/services.dart';

class CourseDetailPage extends StatefulWidget {
  final Course course;

  const CourseDetailPage({
    super.key,
    required this.course,
  });

  @override
  State<CourseDetailPage> createState() => _CourseDetailPageState();
}

class _CourseDetailPageState extends State<CourseDetailPage> {
  Widget _actionCard(
    IconData icon,
    String title,
    String subtitle,
    Color color,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.large),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.large),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.large),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 26),
              ),
              const Spacer(),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.course.title),
        actions: [
          PopupMenuButton<String>(
            tooltip: 'Course actions',
            onSelected: (value) async {
              final CourseService service = CourseService();
              if (value == 'edit') {
                final updated = await Navigator.push<bool?>(
                  context,
                  MaterialPageRoute(builder: (_) => EditCoursePage(course: widget.course)),
                );
                if (updated == true) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Course updated')));
                  setState(() {});
                }
              } else if (value == 'share') {
                await Clipboard.setData(ClipboardData(text: widget.course.courseCode));
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Course code copied to clipboard')));
              } else if (value == 'delete') {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Delete course'),
                    content: Text("Are you sure you want to delete '${widget.course.title}'?"),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                      ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
                    ],
                  ),
                );
                if (confirmed == true) {
                  try {
                    await service.deleteCourse(widget.course.id);
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Course deleted')));
                    Navigator.pop(context);
                  } catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                  }
                }
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'edit', child: Text('Edit')),
              const PopupMenuItem(value: 'share', child: Text('Copy course code')),
              const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
            ],
            icon: const Icon(Icons.more_horiz_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.accent,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.xlarge),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.18),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.school_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            widget.course.title,
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.course.description.isNotEmpty
                          ? widget.course.description
                          : 'A well-structured course ready for materials, quizzes, and AI-powered learning tools.',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _infoChip(
                            Icons.vpn_key_rounded, widget.course.courseCode),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Quick actions',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 1.05,
                children: [
                  _actionCard(
                    Icons.folder_open_rounded,
                    'Materials',
                    'Browse course files',
                    AppColors.warning,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LearningMaterialsPage(
                            course: widget.course,
                          ),
                        ),
                      );
                    },
                  ),
                  _actionCard(
                    Icons.quiz_rounded,
                    'Quizzes',
                    'Review assessments',
                    AppColors.success,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => QuizListPage(
                            course: widget.course,
                          ),
                        ),
                      );
                    },
                  ),
                  _actionCard(
                    Icons.auto_awesome_rounded,
                    'AI Quiz',
                    'Generate smart quizzes',
                    AppColors.accent,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AIQuizPage(
                            course: widget.course,
                          ),
                        ),
                      );
                    },
                  ),
                  _actionCard(
                    Icons.slideshow_rounded,
                    'Presentations',
                    'Generate & manage slides',
                    AppColors.primary,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PresentationsPage(
                            course: widget.course,
                          ),
                        ),
                      );
                    },
                  ),
                  _actionCard(
                    Icons.description_rounded,
                    'AI Exam',
                    'Build exam content',
                    AppColors.danger,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AIExamPage(
                            course: widget.course,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

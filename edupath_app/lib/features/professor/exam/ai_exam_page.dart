import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';

import '../../../core/services/ai_exam_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../models/course.dart';

class AIExamPage extends StatefulWidget {
  final Course course;

  const AIExamPage({
    super.key,
    required this.course,
  });

  @override
  State<AIExamPage> createState() => _AIExamPageState();
}

class _AIExamPageState extends State<AIExamPage> {
  final AIExamService service = AIExamService();
  final TextEditingController topicController = TextEditingController();

  bool loading = false;
  String exam = '';
  String difficulty = 'Medium';

  int mcq = 10;
  int tf = 5;
  int identification = 5;
  int essay = 2;

  Future<void> generateExam() async {
    if (topicController.text.trim().isEmpty) return;

    setState(() => loading = true);

    try {
      final result = await service.generateExam(
        courseId: widget.course.id,
        topic: topicController.text.trim(),
        mcq: mcq,
        tf: tf,
        identification: identification,
        essay: essay,
        difficulty: difficulty,
      );

    // Normalize/extract exam text. Service may return String or Map/List.
    String normalized = '';
    if (result is String) {
      // If it's JSON string, pretty-print it to be readable
      try {
        final decoded = jsonDecode(result);
        normalized = const JsonEncoder.withIndent('  ').convert(decoded);
      } catch (_) {
        normalized = result;
      }
    } else if (result is Map || result is List) {
      normalized = const JsonEncoder.withIndent('  ').convert(result);
    } else if (result != null) {
      normalized = result.toString();
    }

    setState(() => exam = normalized);
    } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(e.toString())),
    );
    }

    if (mounted) {
    setState(() => loading = false);
    }
  }

  Future<void> downloadExam() async {
    try {
      final file = await service.downloadExam(
        courseId: widget.course.id,
        topic: topicController.text.trim(),
        mcq: mcq,
        tf: tf,
        identification: identification,
        essay: essay,
        difficulty: difficulty,
      );

      await OpenFilex.open(file.path);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<void> downloadExamPdf() async {
    try {
      final file = await service.downloadExamPdf(
        courseId: widget.course.id,
        topic: topicController.text.trim(),
        mcq: mcq,
        tf: tf,
        identification: identification,
        essay: essay,
        difficulty: difficulty,
      );

      await OpenFilex.open(file.path);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Examination Generator'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.accent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.xlarge),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.description_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Create an AI exam',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Describe the topic and choose the structure you want for your assessment.',
                      style: TextStyle(
                        color: Colors.white70,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.large),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Exam setup',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: topicController,
                      decoration: const InputDecoration(
                        labelText: 'Topic',
                        prefixIcon: Icon(Icons.topic_rounded),
                      ),
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      value: difficulty,
                      decoration: const InputDecoration(
                        labelText: 'Difficulty',
                        prefixIcon: Icon(Icons.speed_rounded),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Easy', child: Text('Easy')),
                        DropdownMenuItem(
                            value: 'Medium', child: Text('Medium')),
                        DropdownMenuItem(value: 'Hard', child: Text('Hard')),
                      ],
                      onChanged: (value) {
                        setState(() => difficulty = value!);
                      },
                    ),
                    const SizedBox(height: 14),
                    _numberField('Multiple Choice Questions', mcq,
                        (value) => mcq = value),
                    const SizedBox(height: 12),
                    _numberField(
                        'True / False Questions', tf, (value) => tf = value),
                    const SizedBox(height: 12),
                    _numberField('Identification Questions', identification,
                        (value) => identification = value),
                    const SizedBox(height: 12),
                    _numberField(
                        'Essay Questions', essay, (value) => essay = value),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: loading ? null : generateExam,
                        icon: loading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.auto_awesome_rounded),
                        label: Text(
                            loading ? 'Generating...' : 'Generate Examination'),
                      ),
                    ),
                  ],
                ),
              ),
              if (exam.isNotEmpty) ...[
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.description_rounded),
                        label: const Text('DOCX'),
                        onPressed: downloadExam,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.picture_as_pdf_rounded),
                        label: const Text('PDF'),
                        onPressed: downloadExamPdf,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 18),
              if (exam.isNotEmpty)
               Container(
                 width: double.infinity,
                 padding: const EdgeInsets.all(18),
                 decoration: BoxDecoration(
                   color: Theme.of(context).colorScheme.surface,
                   borderRadius: BorderRadius.circular(AppRadius.large),
                   border: Border.all(color: Theme.of(context).dividerColor),
                 ),
                 child: SelectableText(
                   exam,
                   style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontFamily: 'monospace', height: 1.6),
                 ),
               )
              else
               Container(
                 width: double.infinity,
                 padding: const EdgeInsets.all(18),
                 decoration: BoxDecoration(
                   color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                   borderRadius: BorderRadius.circular(AppRadius.large),
                 ),
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     Icon(Icons.lightbulb_rounded, color: Theme.of(context).colorScheme.primary),
                     const SizedBox(height: 8),
                     Text(
                       'Your generated exam will appear here.',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Fill in the topic and click generate to create a polished assessment.',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _numberField(String label, int value, Function(int) onChanged) {
    return TextFormField(
      initialValue: value.toString(),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.format_list_numbered_rounded),
      ),
      keyboardType: TextInputType.number,
      onChanged: (newValue) {
        final parsed = int.tryParse(newValue) ?? value;
        onChanged(parsed);
      },
    );
  }
}

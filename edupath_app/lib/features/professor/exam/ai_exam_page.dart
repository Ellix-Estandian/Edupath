import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';

import '../../../core/services/ai_exam_service.dart';
import '../../../core/services/learning_material_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../models/course.dart';
import '../../../models/learning_material.dart';
import '../assessment_setup_page.dart';
import 'exam_review_page.dart';

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
  final LearningMaterialService materialService = LearningMaterialService();

  bool loading = false;
  bool loadingMaterials = true;
  String exam = '';
  AssessmentSetup? assessmentSetup;
  List<LearningMaterial> materials = [];
  final List<_ExamPart> parts = [_ExamPart(type: 'Multiple Choice', count: 10)];

  @override
  void initState() {
    super.initState();
    _loadMaterials();
  }

  Future<void> _loadMaterials() async {
    try {
      materials = await materialService.getMaterials(widget.course.id);
    } finally {
      if (mounted) setState(() => loadingMaterials = false);
    }
  }

  Future<void> generateExam() async {
    setState(() => loading = true);

    try {
      final result = await service.generateExam(
        courseId: widget.course.id,
        topic: _examTopic(),
        parts: _partPayload(),
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

    if (!mounted) return;
    final reviewed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => ExamReviewPage(exam: normalized)),
    );
    if (reviewed != true || !mounted) return;
    setState(() => exam = normalized);
    final setup = await Navigator.push<AssessmentSetup>(
      context,
      MaterialPageRoute(
        builder: (_) => AssessmentSetupPage(
          assessmentLabel: 'Exam',
          initialTitle: widget.course.title,
        ),
      ),
    );
    if (setup != null && mounted) {
      setState(() => assessmentSetup = setup);
    }
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
        topic: _examTopic(),
        parts: _partPayload(),
        examTitle: assessmentSetup?.title,
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
        topic: _examTopic(),
        parts: _partPayload(),
        examTitle: assessmentSetup?.title,
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
                    Text(
                      'Exam parts',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Add only the parts you need, then connect each part to a lesson and learning objective.',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 12),
                    ...List.generate(parts.length, _buildPartCard),
                    OutlinedButton.icon(
                      onPressed: () => setState(
                        () => parts.add(_ExamPart(type: 'Multiple Choice', count: 5)),
                      ),
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Add exam part'),
                    ),
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
                if (assessmentSetup != null)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(AppRadius.large),
                    ),
                    child: Text(
                      '${assessmentSetup!.title} • ${assessmentSetup!.durationMinutes} minutes\n'
                      'Available ${assessmentSetup!.startsAt.toLocal()} to ${assessmentSetup!.endsAt.toLocal()}',
                    ),
                  ),
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

  List<Map<String, dynamic>> _partPayload() => parts
      .where((part) => part.count > 0)
      .map((part) => part.toJson())
      .toList();

  Widget _buildPartCard(int index) {
    final part = parts[index];
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('Part ${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
                if (parts.length > 1)
                  IconButton(
                    tooltip: 'Remove part',
                    onPressed: () => setState(() => parts.removeAt(index)),
                    icon: const Icon(Icons.delete_outline_rounded),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: part.type,
              decoration: const InputDecoration(labelText: 'Question type'),
              items: const [
                'Multiple Choice',
                'True / False',
                'Identification',
                'Essay',
                'Short Answer',
                'Fill in the Blank',
                'Matching Type',
                'Enumeration',
                'Problem Solving',
                'Case Analysis',
              ]
                  .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                  .toList(),
              onChanged: (value) => setState(() => part.type = value!),
            ),
            const SizedBox(height: 10),
            TextFormField(
              initialValue: part.count.toString(),
              decoration: const InputDecoration(labelText: 'Number of questions'),
              keyboardType: TextInputType.number,
              onChanged: (value) => part.count = int.tryParse(value) ?? 0,
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: part.materialId,
              decoration: const InputDecoration(labelText: 'Connected lesson / material'),
              items: [
                const DropdownMenuItem(value: null, child: Text('Any course material')),
                ...materials.map((material) => DropdownMenuItem(
                      value: material.id,
                      child: Text(material.fileName, overflow: TextOverflow.ellipsis),
                    )),
              ],
              onChanged: loadingMaterials
                  ? null
                  : (value) => setState(() => part.materialId = value),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: part.objectiveController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Learning objective for this part',
                      hintText: 'e.g. Analyze how inheritance reduces code duplication.',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  tooltip: 'Generate AI learning objective',
                  onPressed: part.generatingObjective ? null : () => _generateObjective(part),
                  icon: part.generatingObjective
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.auto_awesome_rounded),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _generateObjective(_ExamPart part) async {
    setState(() => part.generatingObjective = true);
    try {
      final objective = await service.generateLearningObjective(
        courseId: widget.course.id,
        topic: _examTopic(),
        materialId: part.materialId,
      );
      if (mounted) part.objectiveController.text = objective;
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) setState(() => part.generatingObjective = false);
    }
  }

  @override
  void dispose() {
    for (final part in parts) {
      part.objectiveController.dispose();
    }
    super.dispose();
  }

  String _examTopic() {
    final selectedNames = <String>{};
    for (final part in parts) {
      for (final material in materials) {
        if (material.id == part.materialId) selectedNames.add(material.fileName);
      }
    }
    return selectedNames.isEmpty ? widget.course.title : selectedNames.join(', ');
  }
}

class _ExamPart {
  _ExamPart({required this.type, required this.count});

  String type;
  int count;
  String? materialId;
  bool generatingObjective = false;
  final TextEditingController objectiveController = TextEditingController();

  Map<String, dynamic> toJson() => {
        'type': type,
        'count': count,
        'learning_objective': objectiveController.text.trim(),
        'material_id': materialId,
      };
}

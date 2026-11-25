import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../core/services/ai_quiz_service.dart';
import '../../../core/services/ai_exam_service.dart';
import '../../../core/services/learning_material_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../assessment_setup_page.dart';
import '../../../models/course.dart';
import '../../../models/learning_material.dart';

class AIQuizPage extends StatefulWidget {
  final Course course;

  const AIQuizPage({
    super.key,
    required this.course,
  });

  @override
  State<AIQuizPage> createState() => _AIQuizPageState();
}

class _AIQuizPageState extends State<AIQuizPage> {
  final AIQuizService service = AIQuizService();
  final LearningMaterialService materialService = LearningMaterialService();
  final topicController = TextEditingController();
  final objectiveController = TextEditingController();

  bool loading = false;
  List<dynamic> questions = [];
  String cognitiveLevel = 'Balanced';
  List<LearningMaterial> materials = [];
  String? materialId;
  bool loadingMaterials = true;
  bool generatingObjective = false;

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

  Future<void> generate() async {
    if (topicController.text.trim().isEmpty) return;

    setState(() => loading = true);

    try {
      final dynamic result = await service.generateQuiz(
        courseId: widget.course.id,
        topic: topicController.text.trim(),
        cognitiveLevel: cognitiveLevel,
        materialId: materialId,
        learningObjective: objectiveController.text.trim(),
      );

      // Normalize result to a List of question maps
      List<dynamic> parsed = [];

      if (result is String) {
        // Try to decode JSON string
        try {
          final decoded = jsonDecode(result as String);
          if (decoded is List)
            parsed = decoded;
          else if (decoded is Map) {
            // Some APIs wrap questions under a key like 'questions'
            if (decoded['questions'] is List)
              parsed = decoded['questions'];
            else
              parsed = [decoded];
          } else {
            parsed = [
              {'question': result.toString(), 'answer': ''}
            ];
          }
        } catch (_) {
          // Not JSON — assume plain text with newline-delimited Q/A (best-effort)
          final lines = (result as String)
              .split('\n')
              .where((l) => l.trim().isNotEmpty)
              .toList();
          parsed = lines.map((l) => {'question': l, 'answer': ''}).toList();
        }
      } else if (result is List) {
        parsed = result;
      } else if (result is Map) {
        if (result['questions'] is List)
          parsed = result['questions'];
        else
          parsed = [result];
      } else {
        parsed = [
          {'question': result.toString(), 'answer': ''}
        ];
      }

      setState(() => questions = parsed);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }

    if (mounted) {
      setState(() => loading = false);
    }
  }

  Future<void> saveQuiz() async {
    if (questions.isEmpty) return;

    final setup = await Navigator.push<AssessmentSetup>(
      context,
      MaterialPageRoute(
        builder: (_) => AssessmentSetupPage(
          assessmentLabel: 'Quiz',
          initialTitle: topicController.text.trim(),
        ),
      ),
    );
    if (setup == null) return;

    try {
      await service.saveQuiz(
        courseId: widget.course.id,
        title: setup.title,
        questions: questions,
        durationMinutes: setup.durationMinutes,
        availableFrom: setup.startsAt,
        availableUntil: setup.endsAt,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Quiz saved successfully!')),
      );

      Navigator.pop(context);
    } catch (e) {
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
        title: const Text('AI Quiz Generator'),
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
                      child: const Icon(Icons.quiz_rounded,
                          color: Colors.white, size: 24),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Generate an AI quiz',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Enter a topic and generate a polished quiz in seconds.',
                      style: TextStyle(color: Colors.white70, height: 1.5),
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
                      'Quiz setup',
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
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: materialId,
                      decoration: const InputDecoration(
                        labelText: 'Connected lesson / material',
                        prefixIcon: Icon(Icons.menu_book_rounded),
                      ),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('Any course material')),
                        ...materials.map((material) => DropdownMenuItem(
                              value: material.id,
                              child: Text(material.fileName, overflow: TextOverflow.ellipsis),
                            )),
                      ],
                      onChanged: loadingMaterials ? null : (value) => setState(() => materialId = value),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TextField(
                            controller: objectiveController,
                            maxLines: 2,
                            decoration: const InputDecoration(
                              labelText: 'Learning objective',
                              hintText: 'What should students demonstrate?',
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filledTonal(
                          tooltip: 'Generate AI learning objective',
                          onPressed: generatingObjective ? null : _generateObjective,
                          icon: generatingObjective
                              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Icon(Icons.auto_awesome_rounded),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _cognitiveLevelField(),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: loading ? null : generate,
                        icon: loading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.auto_awesome_rounded),
                        label:
                            Text(loading ? 'Generating...' : 'Generate Quiz'),
                      ),
                    ),
                    if (questions.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: saveQuiz,
                          icon: const Icon(Icons.save_rounded),
                          label: const Text('Set up & save quiz'),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 18),
              if (questions.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(AppRadius.large),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.lightbulb_rounded,
                          color: Theme.of(context).colorScheme.primary),
                      const SizedBox(height: 8),
                      Text(
                        'Your generated quiz will appear here.',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Add a topic and generate a focused set of quiz questions.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.color
                                ?.withOpacity(0.8)),
                      ),
                    ],
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: questions.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, index) {
                    final q = questions[index];
                    // Support both Map and simple String representations
                    final questionText = (q is Map)
                        ? (q['question'] ?? q['text'] ?? q.toString())
                        : q.toString();
                    final answerText =
                        (q is Map) ? (q['answer'] ?? q['answers'] ?? '') : '';
                    final questionLevel =
                        (q is Map) ? q['cognitive_level']?.toString() : null;

                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(AppRadius.large),
                        border:
                            Border.all(color: Theme.of(context).dividerColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            questionText.toString(),
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          if (questionLevel == 'LOS' || questionLevel == 'HOS') ...[
                            const SizedBox(height: 8),
                            _cognitiveLevelBadge(questionLevel!),
                          ],
                          const SizedBox(height: 8),
                          if (answerText != null &&
                              answerText.toString().isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 8),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .secondary
                                    .withOpacity(0.08),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                'Answer: ${answerText.toString()}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cognitiveLevelField() {
    return DropdownButtonFormField<String>(
      value: cognitiveLevel,
      decoration: const InputDecoration(
        labelText: 'Cognitive level',
        prefixIcon: Icon(Icons.psychology_alt_rounded),
      ),
      items: const [
        DropdownMenuItem(
          value: 'Balanced',
          child: Text('Balanced (LOS & HOS)'),
        ),
        DropdownMenuItem(
          value: 'LOS',
          child: Text('LOS — recall, understand, apply'),
        ),
        DropdownMenuItem(
          value: 'HOS',
          child: Text('HOS — analyze, evaluate, solve'),
        ),
      ],
      onChanged: (value) => setState(() => cognitiveLevel = value!),
    );
  }

  Widget _cognitiveLevelBadge(String level) {
    final isHigherOrder = level == 'HOS';
    final color = isHigherOrder ? AppColors.accent : AppColors.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$level · ${isHigherOrder ? 'Higher-order skill' : 'Lower-order skill'}',
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }

  Future<void> _generateObjective() async {
    if (topicController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter a quiz topic first.')));
      return;
    }
    setState(() => generatingObjective = true);
    try {
      final objective = await AIExamService().generateLearningObjective(
        courseId: widget.course.id,
        topic: topicController.text.trim(),
        materialId: materialId,
      );
      if (mounted) objectiveController.text = objective;
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) setState(() => generatingObjective = false);
    }
  }

  @override
  void dispose() {
    topicController.dispose();
    objectiveController.dispose();
    super.dispose();
  }
}

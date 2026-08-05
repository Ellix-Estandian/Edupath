import 'package:flutter/material.dart';

import '../../../core/services/ai_exam_service.dart';
import '../../../models/course.dart';
import 'package:open_filex/open_filex.dart';

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

  String exam = "";
  String difficulty = "Medium";

  int mcq = 10;
  int tf = 5;
  int identification = 5;
  int essay = 2;

  Future<void> generateExam() async {
    if (topicController.text.trim().isEmpty) return;

    setState(() {
      loading = true;
    });

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

      setState(() {
        exam = result;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }

    setState(() {
      loading = false;
    });
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
        SnackBar(
          content: Text(e.toString()),
        ),
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
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Examination Generator"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: topicController,
              decoration: const InputDecoration(
                labelText: "Topic",
                border: OutlineInputBorder(),
              ),
            ),
            DropdownButtonFormField<String>(
              value: difficulty,
              decoration: const InputDecoration(
                labelText: "Difficulty",
              ),
              items: const [
                DropdownMenuItem(value: "Easy", child: Text("Easy")),
                DropdownMenuItem(value: "Medium", child: Text("Medium")),
                DropdownMenuItem(value: "Hard", child: Text("Hard")),
              ],
              onChanged: (value) {
                setState(() {
                  difficulty = value!;
                });
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: mcq.toString(),
              decoration: const InputDecoration(
                labelText: "Multiple Choice Questions",
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                mcq = int.tryParse(value) ?? 10;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: tf.toString(),
              decoration: const InputDecoration(
                labelText: "True / False Questions",
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                tf = int.tryParse(value) ?? 5;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: identification.toString(),
              decoration: const InputDecoration(
                labelText: "Identification Questions",
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                identification = int.tryParse(value) ?? 5;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: essay.toString(),
              decoration: const InputDecoration(
                labelText: "Essay Questions",
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                essay = int.tryParse(value) ?? 2;
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: loading ? null : generateExam,
              icon: const Icon(Icons.auto_awesome),
              label: const Text("Generate Examination"),
            ),
            if (exam.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.description),
                        label: const Text("DOCX"),
                        onPressed: downloadExam,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.picture_as_pdf),
                        label: const Text("PDF"),
                        onPressed: downloadExamPdf,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 20),
            if (loading) const CircularProgressIndicator(),
            if (!loading)
              Expanded(
                child: SingleChildScrollView(
                  child: SelectableText(
                    exam,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

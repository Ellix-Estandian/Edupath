import 'package:flutter/material.dart';

import '../../../core/services/quiz_service.dart';
import '../../../models/quiz_answer.dart';

class EditAnswerPage extends StatefulWidget {
  final QuizAnswer answer;

  const EditAnswerPage({
    super.key,
    required this.answer,
  });

  @override
  State<EditAnswerPage> createState() => _EditAnswerPageState();
}

class _EditAnswerPageState extends State<EditAnswerPage> {
  final QuizService service = QuizService();
  late final TextEditingController answerController;

  bool isCorrect = false;
  bool loading = false;

  @override
  void initState() {
    super.initState();

    answerController = TextEditingController(
      text: widget.answer.answer,
    );

    isCorrect = widget.answer.isCorrect;
  }

  Future<void> updateAnswer() async {
    if (answerController.text.trim().isEmpty) return;

    setState(() {
      loading = true;
    });

    await service.updateAnswer(
      id: widget.answer.id,
      answer: answerController.text.trim(),
      isCorrect: isCorrect,
    );

    if (!mounted) return;

    Navigator.pop(context, true);
  }

  @override
  void dispose() {
    answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Answer'),
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        foregroundColor: theme.colorScheme.onBackground,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [theme.colorScheme.primary.withOpacity(0.08), theme.colorScheme.secondary.withOpacity(0.03)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.edit, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Edit Answer',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Modify the answer text and its correctness flag.',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: answerController,
                      maxLines: 3,
                      minLines: 1,
                      decoration: InputDecoration(
                        hintText: 'Edit answer choice',
                        labelText: 'Answer Choice',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                      textCapitalization: TextCapitalization.sentences,
                    ),

                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Icon(isCorrect ? Icons.check_circle : Icons.radio_button_unchecked, color: isCorrect ? theme.colorScheme.primary : theme.hintColor),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Mark as correct answer',
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: isCorrect,
                          activeColor: theme.colorScheme.primary,
                          onChanged: (v) => setState(() => isCorrect = v),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: loading ? null : () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: loading ? null : updateAnswer,
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
                                      Text('Saving...'),
                                    ],
                                  )
                                : const Text('Save Changes'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            Center(
              child: Text(
                'Tip: Keep answer choices concise for better clarity.',
                style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

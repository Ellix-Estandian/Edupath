import 'package:flutter/material.dart';

class ExamReviewPage extends StatelessWidget {
  const ExamReviewPage({super.key, required this.exam});

  final String exam;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Review examination')),
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Text(
                'Review the generated questions and answer keys before continuing to assessment setup.',
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: SelectableText(exam, style: const TextStyle(height: 1.55)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context, true),
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: const Text('Continue to setup'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

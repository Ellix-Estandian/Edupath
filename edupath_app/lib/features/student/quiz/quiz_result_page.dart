import 'package:flutter/material.dart';

class QuizResultPage extends StatelessWidget {
  final int score;
  final int total;

  const QuizResultPage({
    super.key,
    required this.score,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = total == 0 ? 0 : (score / total * 100).round();
    final theme = Theme.of(context);
    final color = percentage >= 80
        ? Colors.green
        : (percentage >= 50 ? Colors.orange : Colors.red);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text('Quiz Result'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.primaryContainer
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(20)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.emoji_events,
                    size: 56,
                    color: Colors.amber,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Quiz Result',
                    style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'See how you performed and next steps',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Result card
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 6,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Score
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '$score',
                            style: theme.textTheme.headlineLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '/$total',
                            style: theme.textTheme.titleLarge,
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Percentage display
                      Text(
                        '$percentage%',
                        style: theme.textTheme.headlineSmall?.copyWith(
                            color: color, fontWeight: FontWeight.w600),
                      ),

                      const SizedBox(height: 12),

                      // Progress bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: percentage / 100.0,
                          minHeight: 12,
                          backgroundColor:
                              theme.colorScheme.onSurface.withOpacity(0.08),
                          valueColor: AlwaysStoppedAnimation<Color>(color),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Message
                      Text(
                        percentage >= 80
                            ? 'Excellent work! Keep it up.'
                            : (percentage >= 50
                                ? 'Good job — a little more practice and you\'ll get there.'
                                : 'Don\'t worry — review the material and try again.'),
                        style: theme.textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 20),

                      // Actions
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Close'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.popUntil(
                                    context, (route) => route.isFirst);
                              },
                              child: const Padding(
                                padding: EdgeInsets.symmetric(vertical: 12.0),
                                child: Text('Finish'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

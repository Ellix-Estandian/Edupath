import 'package:flutter/material.dart';

import '../../../core/services/quiz_service.dart';
import '../../../models/quiz.dart';

class QuizResultsPage extends StatefulWidget {
  final Quiz quiz;

  const QuizResultsPage({
    super.key,
    required this.quiz,
  });

  @override
  State<QuizResultsPage> createState() => _QuizResultsPageState();
}

class _QuizResultsPageState extends State<QuizResultsPage> {
  final QuizService service = QuizService();

  double averageScore = 0;
  int highestScore = 0;
  int lowestScore = 0;
  int totalAttempts = 0;

  List<Map<String, dynamic>> results = [];

  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadResults();
  }

  Future<void> loadResults() async {
    results = await service.getQuizResults(widget.quiz.id);

    totalAttempts = results.length;

    if (results.isNotEmpty) {
        int total = 0;

        highestScore = results.first['score'];
        lowestScore = results.first['score'];

        for (final result in results) {
          final score = result['score'] as int;

          total += score;

          if (score > highestScore) {
            highestScore = score;
          }

          if (score < lowestScore) {
            lowestScore = score;
          }
        }

        averageScore = total / totalAttempts;
    }

    if (!mounted) return;

    setState(() {
      loading = false;
    });
  }

  Widget summaryCard(
    String title,
    String value,
    IconData icon,
  ) {
      final theme = Theme.of(context);

      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 28, color: theme.colorScheme.primary),
              const SizedBox(height: 10),
              Text(
                value,
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(title, style: theme.textTheme.bodySmall),
            ],
          ),
        ),
      );
  }

  void _onExport() {
      // Placeholder: exporting handled elsewhere. Keep UI friendly.
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Export not implemented yet')));
  }

  @override
  Widget build(BuildContext context) {
      final theme = Theme.of(context);

      return Scaffold(
        appBar: AppBar(
          title: Text('${widget.quiz.title} Results'),
          elevation: 0,
          backgroundColor: theme.scaffoldBackgroundColor,
          foregroundColor: theme.colorScheme.onBackground,
          actions: [
            IconButton(
              tooltip: 'Export results',
              icon: const Icon(Icons.download),
              onPressed: _onExport,
            ),
          ],
        ),
        body: loading
            ? const Center(child: CircularProgressIndicator())
            : results.isEmpty
                ? Center(
                    child: Text('No submissions yet.', style: theme.textTheme.bodyLarge),
                  )
                : RefreshIndicator(
                    onRefresh: loadResults,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Top summary row
                          Row(
                            children: [
                              Expanded(child: summaryCard('Attempts', '$totalAttempts', Icons.assignment)),
                              const SizedBox(width: 12),
                              Expanded(child: summaryCard('Average', averageScore > 0 ? '${averageScore.toStringAsFixed(1)}%' : '0%', Icons.bar_chart)),
                              const SizedBox(width: 12),
                              Expanded(child: summaryCard('Highest', '$highestScore', Icons.emoji_events)),
                              const SizedBox(width: 12),
                              Expanded(child: summaryCard('Lowest', '$lowestScore', Icons.trending_down)),
                            ],
                          ),

                          const SizedBox(height: 18),

                          // Student results header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Student Results', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                              Text('$totalAttempts submissions', style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // Student list
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: results.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final result = results[index];
                              final profile = result['profiles'] as Map<String, dynamic>;
                              final score = (result['score'] as num).toDouble();
                              final total = (result['total_items'] as num).toDouble();
                              final pct = total > 0 ? (score / total) : 0.0;

                              return Card(
                                elevation: 1,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 22,
                                        backgroundColor: theme.colorScheme.primary.withOpacity(0.12),
                                        child: const Icon(Icons.person, color: Colors.white),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(profile['full_name'] ?? profile['email'] ?? 'Unknown', style: theme.textTheme.bodyLarge),
                                            const SizedBox(height: 6),
                                            Text('${score.round()} / ${total.round()}', style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
                                            const SizedBox(height: 8),
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(6),
                                              child: LinearProgressIndicator(
                                                value: pct,
                                                minHeight: 8,
                                                backgroundColor: theme.dividerColor,
                                                valueColor: AlwaysStoppedAnimation<Color>(
                                                  pct >= 0.75 ? Colors.green : (pct >= 0.5 ? Colors.orange : Colors.red),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text('${(pct * 100).round()}%', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                                          const SizedBox(height: 8),
                                          PopupMenuButton<String>(
                                            onSelected: (v) {
                                              if (v == 'view') {
                                                showDialog(
                                                  context: context,
                                                  builder: (_) => AlertDialog(
                                                    title: const Text('Result details'),
                                                    content: Text('Score: ${score.round()} / ${total.round()}\nUser: ${profile['full_name'] ?? profile['email']}'),
                                                    actions: [
                                                      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
                                                    ],
                                                  ),
                                                );
                                              } else if (v == 'export') {
                                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Export for this entry not implemented')));
                                              }
                                            },
                                            itemBuilder: (_) => const [
                                              PopupMenuItem(value: 'view', child: Text('View details')),
                                              PopupMenuItem(value: 'export', child: Text('Export entry')),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 20),

                          // Small note
                          Text('Tip: Use the export button to download CSV of results for offline analysis.', style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor), textAlign: TextAlign.center),
                        ],
                      ),
                    ),
                  ),
      );
  }
}

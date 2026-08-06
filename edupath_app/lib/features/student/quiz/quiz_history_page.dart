import 'package:flutter/material.dart';

import '../../../core/services/quiz_service.dart';

class QuizHistoryPage extends StatefulWidget {
  const QuizHistoryPage({super.key});

  @override
  State<QuizHistoryPage> createState() => _QuizHistoryPageState();
}

class _QuizHistoryPageState extends State<QuizHistoryPage> {
  final QuizService service = QuizService();

  List<Map<String, dynamic>> history = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  Future<void> loadHistory() async {
    history = await service.getStudentQuizHistory();

    if (!mounted) return;

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz History'),
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        foregroundColor: theme.colorScheme.onBackground,
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: loadHistory,
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: loadHistory,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [theme.colorScheme.primary, theme.colorScheme.primary.withOpacity(0.9)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.16),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.history_rounded, color: Colors.white),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Quiz History', style: theme.textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
                                  const SizedBox(height: 6),
                                  Text('See how your practice is improving over time.', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  if (history.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Card(
                            elevation: 1,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.quiz_outlined, size: 56, color: theme.colorScheme.primary),
                                  const SizedBox(height: 12),
                                  Text('No quiz attempts yet', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                                  const SizedBox(height: 8),
                                  Text('Your completed quizzes will appear here.', style: theme.textTheme.bodySmall, textAlign: TextAlign.center),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final item = history[index];
                            final quiz = item['quizzes'];

                            final score = item['score'] as int;
                            final total = item['total_items'] as int;
                            final percentage = total == 0 ? 0 : ((score / total) * 100).round();

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Card(
                                elevation: 2,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                child: InkWell(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                        title: Text(quiz['title']),
                                        content: Text('Score: $score / $total'),
                                        actions: [
                                          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
                                        ],
                                      ),
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 56,
                                          height: 56,
                                          decoration: BoxDecoration(
                                            color: theme.colorScheme.primary.withOpacity(0.12),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Icon(Icons.quiz_rounded, color: theme.colorScheme.primary),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(quiz['title'], style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                                              const SizedBox(height: 6),
                                              Text('$score / $total correct', style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
                                              const SizedBox(height: 8),
                                              ClipRRect(
                                                borderRadius: BorderRadius.circular(6),
                                                child: LinearProgressIndicator(
                                                  value: percentage / 100,
                                                  minHeight: 8,
                                                  backgroundColor: theme.dividerColor,
                                                  valueColor: AlwaysStoppedAnimation<Color>(
                                                    percentage >= 75 ? Colors.green : (percentage >= 50 ? Colors.orange : Colors.red),
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
                                            Text('$percentage%', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                                            const SizedBox(height: 8),
                                            Text(item['attempted_at']?.toString() ?? '', style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                          childCount: history.length,
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}

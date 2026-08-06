import 'package:flutter/material.dart';

import '../../../core/services/quiz_service.dart';
import '../../../models/course.dart';
import '../../../models/quiz.dart';
import 'take_quiz_page.dart';

class StudentQuizListPage extends StatefulWidget {
  final Course course;

  const StudentQuizListPage({
    super.key,
    required this.course,
  });

  @override
  State<StudentQuizListPage> createState() => _StudentQuizListPageState();
}

class _StudentQuizListPageState extends State<StudentQuizListPage> {
  final QuizService service = QuizService();

  List<Quiz> quizzes = [];
  bool loading = true;
  String query = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadQuizzes();
    _searchController.addListener(() {
      setState(() {
        query = _searchController.text.trim();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> loadQuizzes() async {
    setState(() {
      loading = true;
    });

    quizzes = await service.getQuizzes(widget.course.id);

    if (!mounted) return;

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filtered = query.isEmpty
        ? quizzes
        : quizzes
            .where((q) => q.title.toLowerCase().contains(query.toLowerCase()) || q.description.toLowerCase().contains(query.toLowerCase()))
            .toList();

    return Scaffold(
      // Use a transparent app bar so the hero header feels part of the screen
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(widget.course.title),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Hero header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [theme.colorScheme.primary, theme.colorScheme.primaryContainer],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quizzes',
                  style: theme.textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  'Take quizzes assigned to this course',
                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 12),
                // Search field
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'Search quizzes',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: query.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                            },
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
              ],
            ),
          ),

          // List / Loading / Empty states
          Expanded(
            child: RefreshIndicator(
              onRefresh: loadQuizzes,
              child: loading
                  ? const Center(child: CircularProgressIndicator())
                  : filtered.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Card(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 4,
                                child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.help_outline, size: 48, color: theme.colorScheme.primary),
                                      const SizedBox(height: 12),
                                      Text('No quizzes found', style: theme.textTheme.titleMedium),
                                      const SizedBox(height: 8),
                                      Text('There are no quizzes for this course yet or your search returned no results.', textAlign: TextAlign.center, style: theme.textTheme.bodySmall),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final quiz = filtered[index];

                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 2,
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                leading: CircleAvatar(
                                  radius: 26,
                                  backgroundColor: theme.colorScheme.primary.withOpacity(0.12),
                                  child: Icon(Icons.quiz, color: theme.colorScheme.primary),
                                ),
                                title: Text(quiz.title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                                subtitle: Text(
                                  quiz.description,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => TakeQuizPage(quiz: quiz)),
                                    );
                                  },
                                  child: const Text('Start'),
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => TakeQuizPage(quiz: quiz)),
                                  );
                                },
                              ),
                            );
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }
}

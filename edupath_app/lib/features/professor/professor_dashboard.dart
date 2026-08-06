import 'package:flutter/material.dart';

import '../../core/services/auth_service.dart';
import '../../core/services/dashboard_service.dart';
import '../../core/services/supabase_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/stat_card.dart';
import '../auth/login_page.dart';
import '../notifications/notification_page.dart';
import 'courses/courses_page.dart';
import '../profile/profile_page.dart';

class ProfessorDashboard extends StatefulWidget {
  const ProfessorDashboard({super.key});

  @override
  State<ProfessorDashboard> createState() => _ProfessorDashboardState();
}

class _ProfessorDashboardState extends State<ProfessorDashboard> {
  final DashboardService service = DashboardService();
  AuthService? _auth;
  AuthService get auth => _auth ??= AuthService();

  bool loading = true;

  Map<String, int> stats = {
    'courses': 0,
    'students': 0,
    'quizzes': 0,
    'materials': 0,
  };

  double averageScore = 0;

  List<Map<String, dynamic>> recentAttempts = [];
  List<Map<String, dynamic>> quizPerformance = [];

  @override
  void initState() {
    super.initState();
    loadStats();
  }

  Future<void> loadStats() async {
    setState(() => loading = true);

    try {
      final nextStats = await service.getProfessorStats();
      final nextAverage = await service.getAverageQuizScore();
      final nextAttempts = await service.getRecentQuizAttempts();
      final nextPerformance = await service.getQuizPerformance();

      if (!mounted) return;
      setState(() {
        stats = nextStats;
        averageScore = nextAverage;
        recentAttempts = nextAttempts;
        quizPerformance = nextPerformance;
        loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => loading = false);
    }
  }

  Future<void> _logout() async {
    try {
      await auth.signOut();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.danger,
          content: Text(e.toString()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Professor Dashboard"),
        centerTitle: false,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const NotificationsPage(),
                ),
              );
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case "profile":
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ProfilePage(),
                    ),
                  );
                  break;

                case "logout":
                  _logout();
                  break;
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: "profile",
                child: ListTile(
                  leading: Icon(Icons.person_outline),
                  title: Text("Profile"),
                ),
              ),
              PopupMenuDivider(),
              PopupMenuItem(
                value: "logout",
                child: ListTile(
                  leading: Icon(Icons.logout),
                  title: Text("Logout"),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF8FAFC), Color(0xFFEFF6FF), Color(0xFFFFF7ED)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: loading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: loadStats,
                  child: CustomScrollView(
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                        sliver: SliverLayoutBuilder(
                          builder: (context, constraints) {
                            final isWide = constraints.crossAxisExtent >= 720;
                            return SliverGrid(
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: isWide ? 4 : 2,
                                crossAxisSpacing: 14,
                                mainAxisSpacing: 14,
                                childAspectRatio: isWide ? 1.22 : 1.05,
                              ),
                              delegate: SliverChildListDelegate(
                                [
                                  StatCard(
                                    title: 'Courses',
                                    value: '${stats['courses']}',
                                    icon: Icons.school_rounded,
                                    color: AppColors.primary,
                                  ),
                                  StatCard(
                                    title: 'Students',
                                    value: '${stats['students']}',
                                    icon: Icons.people_alt_rounded,
                                    color: AppColors.secondary,
                                  ),
                                  StatCard(
                                    title: 'Quizzes',
                                    value: '${stats['quizzes']}',
                                    icon: Icons.quiz_rounded,
                                    color: AppColors.accent,
                                  ),
                                  StatCard(
                                    title: 'Materials',
                                    value: '${stats['materials']}',
                                    icon: Icons.folder_rounded,
                                    color: AppColors.success,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                          child: _ManageCoursesCard(
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const CoursesPage(),
                                ),
                              );
                              loadStats();
                            },
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                          child: Text(
                            'Recent submissions',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                      ),
                      if (recentAttempts.isEmpty)
                        const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(20, 0, 20, 28),
                            child: _EmptyPanel(
                              icon: Icons.history_rounded,
                              text:
                                  'No recent submissions yet. New student quiz attempts will land here.',
                            ),
                          ),
                        )
                      else
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                          sliver: SliverList.separated(
                            itemBuilder: (context, index) {
                              return _RecentAttemptTile(
                                attempt: recentAttempts[index],
                              );
                            },
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 10),
                            itemCount: recentAttempts.length,
                          ),
                        ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

class _ProfessorHeader extends StatefulWidget {
  const _ProfessorHeader({
    required this.averageScore,
  });

  final double averageScore;

  @override
  State<_ProfessorHeader> createState() => _ProfessorHeaderState();
}

class _ProfessorHeaderState extends State<_ProfessorHeader> {
  String displayName = '';

  @override
  void initState() {
    super.initState();
    _loadName();
  }

  Future<void> _loadName() async {
    try {
      final userId = AuthService().currentUser?.id;
      if (userId == null) return;
      final profile = await SupabaseService.client
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();
      if (mounted) {
        setState(() {
          displayName = (profile['full_name'] ?? '') as String;
        });
      }
    } catch (_) {
      // ignore errors — leave displayName empty
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withOpacity(0.95),
            theme.colorScheme.secondary.withOpacity(0.08)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Icon(
              Icons.insights_rounded,
              size: 140,
              color: Colors.white.withOpacity(0.06),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.workspace_premium_rounded,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName.isNotEmpty
                              ? 'Welcome back, $displayName'
                              : 'Professor Dashboard',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ManageCoursesCard extends StatelessWidget {
  const _ManageCoursesCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.menu_book_rounded,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Manage courses',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_rounded, color: theme.hintColor),
            ],
          ),
        ),
      ),
    );
  }
}

class _PerformanceTile extends StatelessWidget {
  const _PerformanceTile({required this.performance});

  final Map<String, dynamic> performance;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = performance['title']?.toString() ?? 'Untitled quiz';
    final average = (performance['average'] as num?)?.toDouble() ?? 0;
    final clamped = average.clamp(0, 100).toDouble();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
                Text(
                  '${average.toStringAsFixed(1)}%',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w900),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: clamped / 100,
                minHeight: 10,
                color: theme.colorScheme.secondary,
                backgroundColor: theme.dividerColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentAttemptTile extends StatelessWidget {
  const _RecentAttemptTile({required this.attempt});

  final Map<String, dynamic> attempt;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final student = attempt['student']?.toString() ?? 'Unknown Student';
    final quiz = attempt['quiz']?.toString() ?? 'Unknown Quiz';
    final score = attempt['score']?.toString() ?? '-';

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: theme.colorScheme.primary.withOpacity(0.12),
              child: const Icon(Icons.person_rounded, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(student, style: theme.textTheme.bodyLarge),
                  const SizedBox(height: 4),
                  Text(quiz,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: theme.hintColor)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(score,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w900)),
          ],
        ),
      ),
    );
  }
}

class _EmptyPanel extends StatelessWidget {
  const _EmptyPanel({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.infoSoft,
              child: Icon(icon, color: AppColors.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(text),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../core/services/auth_service.dart';
import '../../core/services/dashboard_service.dart';
import '../../core/services/supabase_service.dart';
import '../../core/theme/app_colors.dart';
import '../auth/login_page.dart';
import '../notifications/notification_page.dart';
import 'courses/join_course_page.dart';
import 'courses/student_courses_page.dart';
import 'quiz/quiz_history_page.dart';

import '../profile/profile_page.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  final DashboardService _dashboardService = DashboardService();

  bool _loading = true;
  Map<String, dynamic> _stats = {
    'courses': 0,
    'completed': 0,
    'average': 0.0,
    'best': 0,
  };
  List<Map<String, dynamic>> _recentAttempts = [];

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    setState(() => _loading = true);

    try {
      final stats = await _dashboardService.getStudentStats();
      final attempts = await _dashboardService.getStudentRecentAttempts();

      if (!mounted) return;
      setState(() {
        _stats = stats;
        _recentAttempts = attempts;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _logout(BuildContext context) async {
    final auth = AuthService();

    try {
      await auth.signOut();
      if (!context.mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    } catch (e) {
      if (!context.mounted) return;
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
        title: const Text("Student Dashboard"),
        centerTitle: false,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            tooltip: "Notifications",
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
                  _logout(context);
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
            colors: [Color(0xFFF8FAFC), Color(0xFFEFF6FF), Color(0xFFECFDF5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _loadDashboard,
                  child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                          child: const _StudentHeader(),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                          child: _StatsStrip(stats: _stats),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
                          child: Text(
                            'Quick actions',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                        sliver: SliverLayoutBuilder(
                          builder: (context, constraints) {
                            final isWide = constraints.crossAxisExtent >= 720;
                            return SliverGrid(
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: isWide ? 3 : 1,
                                mainAxisExtent: 132,
                                crossAxisSpacing: 14,
                                mainAxisSpacing: 14,
                              ),
                              delegate: SliverChildListDelegate(
                                [
                                  _ActionTile(
                                    icon: Icons.group_add_rounded,
                                    title: 'Join Course',
                                    subtitle:
                                        'Use a class code to enter a new learning space.',
                                    color: AppColors.primary,
                                    onTap: () async {
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const JoinCoursePage(),
                                        ),
                                      );
                                      _loadDashboard();
                                    },
                                  ),
                                  _ActionTile(
                                    icon: Icons.menu_book_rounded,
                                    title: 'My Courses',
                                    subtitle:
                                        'Continue lessons, files, quizzes, and activities.',
                                    color: AppColors.secondary,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const StudentCoursesPage(),
                                        ),
                                      );
                                    },
                                  ),
                                  _ActionTile(
                                    icon: Icons.history_rounded,
                                    title: 'Quiz History',
                                    subtitle:
                                        'Review attempts and see how your scores move.',
                                    color: AppColors.accent,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const QuizHistoryPage(),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Recent activity',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const QuizHistoryPage(),
                                    ),
                                  );
                                },
                                child: const Text('View all'),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (_recentAttempts.isEmpty)
                        const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(20, 0, 20, 28),
                            child: _EmptyActivity(),
                          ),
                        )
                      else
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                          sliver: SliverList.separated(
                            itemBuilder: (context, index) {
                              return _AttemptTile(
                                attempt: _recentAttempts[index],
                              );
                            },
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 10),
                            itemCount: _recentAttempts.length,
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

class _StudentHeader extends StatefulWidget {
  const _StudentHeader({super.key});

  @override
  State<_StudentHeader> createState() => _StudentHeaderState();
}

class _StudentHeaderState extends State<_StudentHeader> {
  String displayName = '';

  @override
  void initState() {
    super.initState();
    _loadName();
  }

  Future<void> _loadName() async {
    try {
      final profile = await SupabaseService.client
          .from('profiles')
          .select()
          .eq('id', AuthService().currentUser?.id ?? '')
          .single();
      if (mounted) {
        setState(() {
          displayName = (profile['full_name'] ?? '') as String;
        });
      }
    } catch (_) {
      // ignore errors — displayName stays empty
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primaryContainer
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -22,
            top: -28,
            child: Icon(
              Icons.auto_stories_rounded,
              size: 150,
              color: Colors.white.withOpacity(0.06),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.school_rounded,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 26),
              Text(
                displayName.isNotEmpty
                    ? 'Welcome back, $displayName'
                    : 'Welcome back',
                style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white, fontWeight: FontWeight.w900),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatsStrip extends StatelessWidget {
  const _StatsStrip({required this.stats});

  final Map<String, dynamic> stats;

  @override
  Widget build(BuildContext context) {
    final average = (stats['average'] as num?)?.round() ?? 0;
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 720;
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: isWide ? 4 : 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: isWide ? 1.55 : 1.25,
          children: [
            _MiniStat(
              label: 'Courses',
              value: '${stats['courses'] ?? 0}',
              icon: Icons.menu_book_rounded,
              color: Theme.of(context).colorScheme.primary,
            ),
            _MiniStat(
              label: 'Completed',
              value: '${stats['completed'] ?? 0}',
              icon: Icons.task_alt_rounded,
              color: Theme.of(context).colorScheme.secondary,
            ),
            _MiniStat(
              label: 'Average',
              value: '$average%',
              icon: Icons.trending_up_rounded,
              color: Theme.of(context).colorScheme.tertiary,
            ),
            _MiniStat(
              label: 'Best',
              value: '${stats['best'] ?? 0}%',
              icon: Icons.workspace_premium_rounded,
              color: Colors.green,
            ),
          ],
        );
      },
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: theme.textTheme.bodyLarge?.color ?? Colors.black,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7)),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_rounded,
                  color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}

class _AttemptTile extends StatelessWidget {
  const _AttemptTile({required this.attempt});

  final Map<String, dynamic> attempt;

  @override
  Widget build(BuildContext context) {
    final quiz = attempt['quizzes'];
    final title = quiz is Map ? quiz['title']?.toString() : 'Quiz attempt';
    final score = attempt['score'] ?? 0;
    final total = attempt['total_items'] ?? 0;

    return Card(
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: AppColors.accentSoft,
          child: Icon(Icons.quiz_rounded, color: AppColors.accent),
        ),
        title: Text(
          title ?? 'Quiz attempt',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: const Text('Latest submitted quiz'),
        trailing: Text(
          '$score/$total',
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _EmptyActivity extends StatelessWidget {
  const _EmptyActivity();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: theme.colorScheme.primary.withOpacity(0.12),
              child: Icon(Icons.bolt_rounded, color: theme.colorScheme.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                'No quiz attempts yet. Once you start taking quizzes, your progress will show up here.',
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

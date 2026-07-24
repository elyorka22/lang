import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../features/auth/application/auth_controller.dart';
import '../../../../shared/data/mock_data.dart';
import '../../../../shared/providers/locale_provider.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../../../../shared/widgets/premium_card.dart';
import '../../../vocabulary/application/vocabulary_controller.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vocab = ref.watch(vocabularyProvider);
    final user = ref.watch(authControllerProvider).user;
    final s = ref.watch(appStringsProvider);
    final stats = MockData.stats;

    if (vocab.isLoading) return const Scaffold(body: HomeShimmer());

    final firstName = user?.displayName.split(' ').first ?? s.learner;
    final goalTarget = 10;
    final goalDone = vocab.learnedToday.clamp(0, goalTarget);
    final goalProgress = (goalDone / goalTarget).clamp(0.0, 1.0);
    final week = stats.weeklyMinutes;
    final weekMax = week.isEmpty ? 1 : week.reduce((a, b) => a > b ? a : b);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref.read(vocabularyProvider.notifier).load(),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.hello(firstName),
                          style: context.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(
                              Icons.local_fire_department_rounded,
                              size: 18,
                              color: AppColors.streakOrange,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              s.dayStreak(user?.streak ?? stats.currentStreak),
                              style: context.textTheme.bodySmall?.copyWith(
                                color: AppColors.streakOrange,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => context.push('/notifications'),
                    style: IconButton.styleFrom(
                      backgroundColor: context.isDark
                          ? AppColors.surfaceElevatedDark
                          : AppColors.secondary,
                    ),
                    icon: const Icon(Icons.notifications_none_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              PremiumCard(
                padding: const EdgeInsets.all(18),
                color: AppColors.primary,
                child: Row(
                  children: [
                    CircularPercentIndicator(
                      radius: 38,
                      lineWidth: 7,
                      percent: goalProgress,
                      animation: true,
                      circularStrokeCap: CircularStrokeCap.round,
                      backgroundColor: Colors.white24,
                      progressColor: Colors.white,
                      center: Text(
                        '$goalDone/$goalTarget',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            s.dailyGoal,
                            style: context.textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            s.wordsLearnedToday(goalDone),
                            style: context.textTheme.bodySmall?.copyWith(
                              color: Colors.white.withOpacity(0.92),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn().slideY(begin: 0.06, end: 0),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => context.go('/practice'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.borderXl,
                  ),
                ),
                child: Text(
                  vocab.dueCount > 0
                      ? s.reviewDue(vocab.dueCount)
                      : s.startPracticing,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 20),
              Text(s.learningStats, style: context.textTheme.titleMedium),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: s.wordsToReview,
                      value: '${vocab.dueCount}',
                      icon: Icons.schedule_rounded,
                      color: AppColors.warning,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StatCard(
                      label: s.mastered,
                      value: '${vocab.masteredCount}',
                      icon: Icons.emoji_events_rounded,
                      color: AppColors.xpGold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: s.accuracy,
                      value: '${(vocab.accuracyToday * 100).round()}%',
                      icon: Icons.check_circle_outline,
                      color: AppColors.success,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StatCard(
                      label: s.pronunciation,
                      value: vocab.pronunciationScores.isEmpty
                          ? '—'
                          : '${vocab.avgPronunciation.round()}',
                      icon: Icons.record_voice_over_outlined,
                      color: AppColors.accent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(s.weeklyProgress, style: context.textTheme.titleMedium),
              const SizedBox(height: 10),
              PremiumCard(
                child: Column(
                  children: [
                    for (var i = 0; i < week.length; i++) ...[
                      if (i > 0) const SizedBox(height: 8),
                      Row(
                        children: [
                          SizedBox(
                            width: 28,
                            child: Text(
                              ['M', 'T', 'W', 'T', 'F', 'S', 'S'][i],
                              style: context.textTheme.labelSmall,
                            ),
                          ),
                          Expanded(
                            child: LinearPercentIndicator(
                              lineHeight: 10,
                              percent: weekMax == 0
                                  ? 0
                                  : (week[i] / weekMax).clamp(0.0, 1.0),
                              barRadius: const Radius.circular(8),
                              progressColor: AppColors.primary,
                              backgroundColor: context.isDark
                                  ? AppColors.borderDark
                                  : AppColors.secondary,
                              padding: EdgeInsets.zero,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text('${week[i]}m', style: context.textTheme.labelSmall),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(s.quickActions, style: context.textTheme.titleMedium),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: QuickActionTile(
                      icon: Icons.menu_book_rounded,
                      label: s.navWords,
                      onTap: () => context.go('/words'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: QuickActionTile(
                      icon: Icons.sports_esports_rounded,
                      label: s.navGames,
                      color: AppColors.accent,
                      onTap: () => context.go('/games'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: QuickActionTile(
                      icon: Icons.style_rounded,
                      label: s.navPractice,
                      color: AppColors.warning,
                      onTap: () => context.go('/practice'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
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
    return PremiumCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 10),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 2),
          Text(label, style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }
}

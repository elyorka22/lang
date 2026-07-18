import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../features/auth/application/auth_controller.dart';
import '../../../../shared/models/goal_map.dart';
import '../../../../shared/providers/locale_provider.dart';
import '../../../../shared/widgets/app_avatar.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../goal_map/application/goal_map_controller.dart';
import '../../application/home_controller.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final home = ref.watch(homeControllerProvider);
    final user = ref.watch(authControllerProvider).user;
    final s = ref.watch(appStringsProvider);

    if (home.isLoading) return const Scaffold(body: HomeShimmer());

    final firstName = user?.displayName.split(' ').first ?? s.learner;
    final goalMap = ref.watch(goalMapControllerProvider).plan;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref.read(homeControllerProvider.notifier).load(),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              s.hello(firstName),
                              style: context.textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.local_fire_department,
                                    size: 18, color: AppColors.streakOrange),
                                const SizedBox(width: 4),
                                Text(
                                  s.dayStreak(
                                    user?.streak ?? home.goal.minutesDone,
                                  ),
                                  style: context.textTheme.bodySmall?.copyWith(
                                    color: AppColors.streakOrange,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Icon(Icons.bolt,
                                    size: 18, color: AppColors.xpGold),
                                const SizedBox(width: 4),
                                Text(
                                  '${user?.xp ?? 0} XP',
                                  style: context.textTheme.bodySmall?.copyWith(
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
                        icon: const Icon(Icons.notifications_none_rounded),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: _DailyGoalCard(
                  progress: home.goal.overallProgress,
                  goalMap: goalMap,
                  title: goalMap == null ? s.dailyGoal : s.goalMap,
                  subtitle: goalMap == null
                      ? s.dailyGoalHint
                      : '${goalMap.title} · ${goalMap.daysLeft}d · ${goalMap.todayDone ? '✓' : ''}',
                  onTap: () => context.push('/goal-map'),
                )
                    .animate()
                    .fadeIn()
                    .slideY(begin: 0.08, end: 0),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                  child: Text(
                    s.explore,
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _ExploreShortcut(
                          icon: Icons.explore_outlined,
                          label: s.discover,
                          color: AppColors.secondary,
                          onTap: () => context.push('/discover'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _ExploreShortcut(
                          icon: Icons.bookmark_border_rounded,
                          label: s.saves,
                          color: AppColors.accent,
                          onTap: () => context.push('/saves'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _ExploreShortcut(
                          icon: Icons.sports_esports_outlined,
                          label: s.games,
                          color: AppColors.primary,
                          onTap: () => context.push('/games'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SectionHeader(title: s.continueLearning).asSliver,
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 112,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      _ContinueCard(
                        icon: Icons.sports_esports_outlined,
                        title: s.games,
                        subtitle: s.questsCards,
                        color: AppColors.primary,
                        onTap: () => context.push('/games'),
                      ),
                      _ContinueCard(
                        icon: Icons.style_outlined,
                        title: s.flashcards,
                        subtitle: s.dueCount(home.reviewCount),
                        color: AppColors.secondary,
                        onTap: () => context.push('/games/flashcards'),
                      ),
                      _ContinueCard(
                        icon: Icons.mic_none_rounded,
                        title: s.speaking,
                        subtitle: s.voiceCoach,
                        color: AppColors.accent,
                        onTap: () => context.push('/ai/voice'),
                      ),
                      _ContinueCard(
                        icon: Icons.groups_2_outlined,
                        title: s.navRooms,
                        subtitle: s.roomsTables,
                        color: AppColors.premiumPurple,
                        onTap: () => context.go('/rooms'),
                      ),
                    ],
                  ),
                ),
              ),
              SectionHeader(
                title: s.aiSuggestions,
                actionLabel: s.games,
                onAction: () => context.push('/games'),
              ).asSliver,
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 44,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: home.suggestions.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, i) {
                      return ActionChip(
                        label: Text(home.suggestions[i]),
                        onPressed: () => context.push('/games/quests'),
                        backgroundColor: context.isDark
                            ? AppColors.surfaceElevatedDark
                            : AppColors.surface,
                      );
                    },
                  ),
                ),
              ),
              SectionHeader(
                title: s.onlineNow,
                actionLabel: s.discover,
                onAction: () => context.push('/discover'),
              ).asSliver,
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 96,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: home.online.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 14),
                    itemBuilder: (_, i) {
                      final u = home.online[i];
                      return GestureDetector(
                        onTap: () => context.push('/users/${u.id}'),
                        child: Column(
                          children: [
                            AppAvatar(
                              name: u.displayName,
                              url: u.avatarUrl,
                              status: u.status,
                              showStatus: true,
                              size: 56,
                            ),
                            const SizedBox(height: 6),
                            SizedBox(
                              width: 64,
                              child: Text(
                                u.displayName.split(' ').first,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: context.textTheme.labelSmall,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              SectionHeader(
                title: s.recommendedGroups,
                actionLabel: s.seeAll,
                onAction: () => context.push('/discover'),
              ).asSliver,
              SliverList.builder(
                itemCount: home.recommendedGroups.length,
                itemBuilder: (_, i) {
                  final g = home.recommendedGroups[i];
                  final langs = g.languageCodes.isEmpty
                      ? ''
                      : g.languageCodes.map((c) => c.toUpperCase()).join(' · ');
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: InkWell(
                      onTap: () => context.push('/chat/${g.id}'),
                      borderRadius: BorderRadius.circular(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          AppAvatar(
                            name: g.displayTitle,
                            url: g.avatarUrl,
                            size: 52,
                            isGroup: true,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  g.displayTitle,
                                  style: context.textTheme.titleSmall,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  g.description.isNotEmpty
                                      ? g.description
                                      : '${g.members.length} members',
                                  style: context.textTheme.bodySmall,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (langs.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    langs,
                                    style: context.textTheme.labelSmall,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            height: 36,
                            child: FilledButton(
                              onPressed: () => context.push('/chat/${g.id}'),
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                ),
                                minimumSize: const Size(0, 36),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                visualDensity: VisualDensity.compact,
                              ),
                              child: Text(s.join),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              SectionHeader(
                title: s.recentChats,
                actionLabel: s.open,
                onAction: () => context.go('/rooms/inbox'),
              ).asSliver,
              SliverList.builder(
                itemCount: home.recentChats.length,
                itemBuilder: (_, i) {
                  final c = home.recentChats[i];
                  return ListTile(
                    onTap: () => context.push('/chat/${c.id}'),
                    leading: AppAvatar(
                      name: c.peer?.displayName ?? c.displayTitle,
                      url: c.peer?.avatarUrl,
                      status: c.peer?.status,
                      showStatus: c.peer != null,
                    ),
                    title: Text(c.displayTitle),
                    subtitle: Text(
                      c.lastMessage?.text ??
                          (c.lastMessage?.type.name == 'voice'
                              ? 'Voice message'
                              : ''),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: c.unreadCount > 0
                        ? CircleAvatar(
                            radius: 11,
                            backgroundColor: AppColors.primary,
                            child: Text(
                              '${c.unreadCount}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.white,
                              ),
                            ),
                          )
                        : null,
                  );
                },
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        ),
      ),
    );
  }
}

class _DailyGoalCard extends StatelessWidget {
  const _DailyGoalCard({
    required this.progress,
    required this.onTap,
    required this.title,
    required this.subtitle,
    this.goalMap,
  });

  final double progress;
  final VoidCallback onTap;
  final String title;
  final String subtitle;
  final GoalMapPlan? goalMap;

  @override
  Widget build(BuildContext context) {
    final mapProgress = goalMap?.displayProgress;
    final shown = mapProgress ?? progress;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: AppColors.brandGradientSoft,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.28),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              CircularPercentIndicator(
                radius: 36,
                lineWidth: 7,
                percent: shown.clamp(0.0, 1.0),
                animation: true,
                circularStrokeCap: CircularStrokeCap.round,
                backgroundColor: Colors.white24,
                progressColor: Colors.white,
                center: Text(
                  '${(shown * 100).round()}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: context.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.chevron_right,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExploreShortcut extends StatelessWidget {
  const _ExploreShortcut({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.isDark
          ? AppColors.surfaceElevatedDark
          : AppColors.surfaceElevated,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Column(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.14),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: context.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContinueCard extends StatelessWidget {
  const _ContinueCard({
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 148,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: context.isDark
              ? AppColors.surfaceElevatedDark
              : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: context.isDark ? AppColors.borderDark : AppColors.border,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const Spacer(),
            Text(title, style: context.textTheme.titleSmall),
            Text(subtitle, style: context.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

extension on Widget {
  Widget get asSliver => SliverToBoxAdapter(child: this);
}

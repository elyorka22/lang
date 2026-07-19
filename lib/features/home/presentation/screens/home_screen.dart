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
import '../../../../shared/models/social_models.dart';
import '../../../../shared/models/user_profile.dart';
import '../../../../shared/providers/locale_provider.dart';
import '../../../../shared/widgets/app_avatar.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../../../../shared/widgets/premium_card.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../goal_map/application/goal_map_controller.dart';
import '../../../social/application/social_controller.dart';
import '../../application/home_controller.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final home = ref.watch(homeControllerProvider);
    final user = ref.watch(authControllerProvider).user;
    final s = ref.watch(appStringsProvider);
    final social = ref.watch(socialControllerProvider);

    if (home.isLoading) return const Scaffold(body: HomeShimmer());

    final firstName = user?.displayName.split(' ').first ?? s.learner;
    final goalMap = ref.watch(goalMapControllerProvider).plan;
    final partners = home.online.take(8).toList();
    final rooms = social.rooms.take(4).toList();

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref.read(homeControllerProvider.notifier).load(),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 12, 8),
                  child: Row(
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
                                  s.dayStreak(
                                    user?.streak ?? home.goal.minutesDone,
                                  ),
                                  style: context.textTheme.bodySmall?.copyWith(
                                    color: AppColors.streakOrange,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                const Icon(
                                  Icons.bolt_rounded,
                                  size: 18,
                                  color: AppColors.xpGold,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${user?.xp ?? 0} XP',
                                  style: context.textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w700,
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
                    .fadeIn(duration: 320.ms)
                    .slideY(begin: 0.06, end: 0),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                  child: FilledButton(
                    onPressed: () => context.go('/ai'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(56),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.borderXl,
                      ),
                    ),
                    child: Text(
                      s.startPracticing,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 80.ms)
                      .scale(
                        begin: const Offset(0.98, 0.98),
                        end: const Offset(1, 1),
                      ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: QuickActionTile(
                          icon: Icons.person_search_rounded,
                          label: s.findPartner,
                          color: AppColors.accent,
                          onTap: () => context.push('/discover'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: QuickActionTile(
                          icon: Icons.graphic_eq_rounded,
                          label: s.joinVoiceRoom,
                          color: AppColors.primary,
                          onTap: () => context.push('/rooms'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: QuickActionTile(
                          icon: Icons.auto_awesome_rounded,
                          label: s.practiceWithAi,
                          color: AppColors.premiumPurple,
                          onTap: () => context.go('/ai'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SectionHeader(
                title: s.peopleOnline,
                actionLabel: s.seeAll,
                onAction: () => context.push('/discover'),
              ).asSliver,
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 100,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
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
                              size: 58,
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: 68,
                              child: Text(
                                u.displayName.split(' ').first,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: context.textTheme.labelMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
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
                title: s.recommendedPartners,
                actionLabel: s.seeAll,
                onAction: () => context.push('/discover'),
              ).asSliver,
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 168,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: partners.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (_, i) => SizedBox(
                      width: 160,
                      height: 168,
                      child: _PartnerCard(
                        user: partners[i],
                        followLabel: s.follow,
                        chatLabel: s.chat,
                      ),
                    ),
                  ),
                ),
              ),
              SectionHeader(
                title: s.continueLearning,
                actionLabel: s.games,
                onAction: () => context.push('/games'),
              ).asSliver,
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 118,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
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
                        color: AppColors.accent,
                        onTap: () => context.push('/games/flashcards'),
                      ),
                      _ContinueCard(
                        icon: Icons.mic_none_rounded,
                        title: s.speaking,
                        subtitle: s.voiceCoach,
                        color: AppColors.warning,
                        onTap: () => context.push('/ai/voice'),
                      ),
                      _ContinueCard(
                        icon: Icons.groups_2_outlined,
                        title: s.navRooms,
                        subtitle: s.roomsTables,
                        color: AppColors.success,
                        onTap: () => context.push('/rooms'),
                      ),
                    ],
                  ),
                ),
              ),
              SectionHeader(
                title: s.vocabularyReview,
                actionLabel: s.review,
                onAction: () => context.go('/vocabulary'),
              ).asSliver,
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: PremiumCard(
                    onTap: () => context.push('/games/flashcards'),
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: AppColors.primarySurface,
                            borderRadius: AppRadius.borderLg,
                          ),
                          child: const Icon(
                            Icons.style_rounded,
                            color: AppColors.primaryDark,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                s.wordsDue(home.reviewCount),
                                style: context.textTheme.titleSmall,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                s.questsCards,
                                style: context.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        FilledButton(
                          onPressed: () =>
                              context.push('/games/flashcards'),
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(0, 40),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                          ),
                          child: Text(s.review),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SectionHeader(
                title: s.trendingVoiceRooms,
                actionLabel: s.seeAll,
                onAction: () => context.push('/social'),
              ).asSliver,
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 148,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: rooms.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (_, i) => SizedBox(
                      width: 212,
                      height: 148,
                      child: _VoiceRoomCard(
                        room: rooms[i],
                        liveLabel: s.live,
                        joinLabel: s.join,
                        onlineLabel: s.onlineCount(rooms[i].onlineCount),
                      ),
                    ),
                  ),
                ),
              ),
              SectionHeader(
                title: s.popularGames,
                actionLabel: s.seeAll,
                onAction: () => context.push('/games'),
              ).asSliver,
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      _GameRow(
                        icon: Icons.style_outlined,
                        color: AppColors.accent,
                        title: s.flashcards,
                        subtitle: s.dueCount(home.reviewCount),
                        action: s.play,
                        onTap: () => context.push('/games/flashcards'),
                      ),
                      const SizedBox(height: 10),
                      _GameRow(
                        icon: Icons.theater_comedy_outlined,
                        color: AppColors.primary,
                        title: 'AI Quest Chat',
                        subtitle: s.questsCards,
                        action: s.play,
                        onTap: () => context.push('/games/quests'),
                      ),
                      const SizedBox(height: 10),
                      _GameRow(
                        icon: Icons.image_search_outlined,
                        color: AppColors.warning,
                        title: 'Picture Words',
                        subtitle: s.games,
                        action: s.play,
                        onTap: () => context.push('/games/picture-words'),
                      ),
                    ],
                  ),
                ),
              ),
              const ContainedSliver(child: SizedBox(height: 28)),
            ],
          ),
        ),
      ),
    );
  }
}

class ContainedSliver extends StatelessWidget {
  const ContainedSliver({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => SliverToBoxAdapter(child: child);
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

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.borderXl,
          child: Ink(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: AppRadius.borderXl,
              boxShadow: AppShadows.primaryGlow,
            ),
            child: Row(
              children: [
                CircularPercentIndicator(
                  radius: 38,
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
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: Colors.white.withOpacity(0.92),
                          height: 1.35,
                        ),
                      ),
                    ],
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

class _PartnerCard extends StatelessWidget {
  const _PartnerCard({
    required this.user,
    required this.followLabel,
    required this.chatLabel,
  });

  final UserProfile user;
  final String followLabel;
  final String chatLabel;

  @override
  Widget build(BuildContext context) {
    final learning = user.learningLanguages.isNotEmpty
        ? user.learningLanguages.first.name
        : '—';

    return PremiumCard(
      padding: const EdgeInsets.all(14),
      onTap: () => context.push('/users/${user.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppAvatar(
                name: user.displayName,
                url: user.avatarUrl,
                status: user.status,
                showStatus: true,
                size: 44,
              ),
              const Spacer(),
              if (user.countryCode != null)
                Text(
                  user.countryCode!,
                  style: context.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            user.displayName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.titleSmall,
          ),
          Text(
            '${user.nativeLanguage} → $learning',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.bodySmall,
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => context.push('/users/${user.id}'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 32),
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                  child: Text(followLabel, style: const TextStyle(fontSize: 12)),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: FilledButton(
                  onPressed: () => context.push('/chat/c_${user.id}'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(0, 32),
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                  child: Text(chatLabel, style: const TextStyle(fontSize: 12)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _VoiceRoomCard extends StatelessWidget {
  const _VoiceRoomCard({
    required this.room,
    required this.liveLabel,
    required this.joinLabel,
    required this.onlineLabel,
  });

  final LanguageRoom room;
  final String liveLabel;
  final String joinLabel;
  final String onlineLabel;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      onTap: () => context.push('/social/rooms/${room.id}'),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(room.topic.emoji, style: const TextStyle(fontSize: 22)),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: AppRadius.borderFull,
                ),
                child: Text(
                  liveLabel,
                  style: context.textTheme.labelSmall?.copyWith(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            room.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.titleSmall,
          ),
          Text(
            onlineLabel,
            style: context.textTheme.bodySmall,
          ),
          const Spacer(),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => context.push('/social/rooms/${room.id}'),
              child: Text(joinLabel),
            ),
          ),
        ],
      ),
    );
  }
}

class _GameRow extends StatelessWidget {
  const _GameRow({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.action,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: AppRadius.borderLg,
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: context.textTheme.titleSmall),
                Text(subtitle, style: context.textTheme.bodySmall),
              ],
            ),
          ),
          Text(
            action,
            style: context.textTheme.labelLarge?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
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
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: PremiumCard(
        onTap: onTap,
        padding: const EdgeInsets.all(14),
        child: SizedBox(
          width: 140,
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
      ),
    );
  }
}

extension on Widget {
  Widget get asSliver => SliverToBoxAdapter(child: this);
}

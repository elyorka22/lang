import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../features/auth/application/auth_controller.dart';
import '../../../../shared/widgets/app_avatar.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../application/home_controller.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final home = ref.watch(homeControllerProvider);
    final user = ref.watch(authControllerProvider).user;

    if (home.isLoading) return const Scaffold(body: HomeShimmer());

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
                              'Hello, ${user?.displayName.split(' ').first ?? 'Learner'}',
                              style: context.textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.local_fire_department,
                                    size: 18, color: AppColors.streakOrange),
                                const SizedBox(width: 4),
                                Text(
                                  '${user?.streak ?? home.goal.minutesDone} day streak',
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
                child: _DailyGoalCard(progress: home.goal.overallProgress)
                    .animate()
                    .fadeIn()
                    .slideY(begin: 0.08, end: 0),
              ),
              const SectionHeader(title: 'Continue learning').asSliver,
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 112,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      _ContinueCard(
                        icon: Icons.smart_toy_outlined,
                        title: 'AI Lesson',
                        subtitle: 'Travel Spanish',
                        color: AppColors.primary,
                        onTap: () => context.go('/ai'),
                      ),
                      _ContinueCard(
                        icon: Icons.style_outlined,
                        title: 'Flashcards',
                        subtitle: '${home.reviewCount} due',
                        color: AppColors.secondary,
                        onTap: () => context.push('/vocabulary/flashcards'),
                      ),
                      _ContinueCard(
                        icon: Icons.mic_none_rounded,
                        title: 'Speaking',
                        subtitle: 'Voice coach',
                        color: AppColors.accent,
                        onTap: () => context.push('/ai/voice'),
                      ),
                    ],
                  ),
                ),
              ),
              SectionHeader(
                title: 'AI suggestions',
                actionLabel: 'All',
                onAction: () => context.go('/ai'),
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
                        onPressed: () => context.go('/ai'),
                        backgroundColor: context.isDark
                            ? AppColors.surfaceElevatedDark
                            : AppColors.surface,
                      );
                    },
                  ),
                ),
              ),
              SectionHeader(
                title: 'Online now',
                actionLabel: 'Discover',
                onAction: () => context.go('/discover'),
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
                title: 'Recommended friends',
                actionLabel: 'See all',
                onAction: () => context.go('/discover'),
              ).asSliver,
              SliverList.builder(
                itemCount: home.recommended.length,
                itemBuilder: (_, i) {
                  final u = home.recommended[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: InkWell(
                      onTap: () => context.push('/users/${u.id}'),
                      borderRadius: BorderRadius.circular(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          AppAvatar(
                            name: u.displayName,
                            url: u.avatarUrl,
                            status: u.status,
                            showStatus: true,
                            size: 52,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  u.displayName,
                                  style: context.textTheme.titleSmall,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${u.nativeLanguage} → ${u.primaryLearning}',
                                  style: context.textTheme.bodySmall,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (u.country != null) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    u.country!,
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
                              onPressed: () =>
                                  context.push('/chat/c_${u.id}'),
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                ),
                                minimumSize: const Size(0, 36),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                visualDensity: VisualDensity.compact,
                              ),
                              child: const Text('Chat'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              SectionHeader(
                title: 'Recent chats',
                actionLabel: 'Open',
                onAction: () => context.go('/chats'),
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
  const _DailyGoalCard({required this.progress});
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Container(
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
            percent: progress,
            animation: true,
            circularStrokeCap: CircularStrokeCap.round,
            backgroundColor: Colors.white24,
            progressColor: Colors.white,
            center: Text(
              '${(progress * 100).round()}%',
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
                Text(
                  'Daily goal',
                  style: context.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Keep your streak alive — a few minutes left today.',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
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

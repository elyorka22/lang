import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/models/game_models.dart';
import '../../../../shared/providers/locale_provider.dart';
import '../../../../shared/widgets/safe_body.dart';
import '../../application/games_controller.dart';

class GamesHubScreen extends ConsumerWidget {
  const GamesHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final games = ref.watch(gamesControllerProvider);
    final quests = GameCatalog.quests;
    final doneCount = quests.where(games.isCompleted).length;
    final s = ref.watch(appStringsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(s.games),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: Text(
                '${games.totalXp} XP',
                style: context.textTheme.labelLarge?.copyWith(
                  color: AppColors.xpGold,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeBody(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            Text(
              s.practiceByPlaying,
              style: context.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              s.gamesHubHint,
              style: context.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _GameTile(
              icon: Icons.style_outlined,
              iconColor: AppColors.secondary,
              title: '1 · ${s.flashcards}',
              subtitle: s.flashcards,
              trailing: s.play,
              onTap: () => context.push('/games/flashcards'),
            ),
            const SizedBox(height: 12),
            _GameTile(
              icon: Icons.theater_comedy_outlined,
              iconColor: AppColors.primary,
              title: '2 · AI Quest Chat',
              subtitle:
                  'Level ${games.unlockedLevel} · $doneCount/${quests.length}',
              trailing: s.levels,
              onTap: () => context.push('/games/quests'),
            ),
            const SizedBox(height: 12),
            _GameTile(
              icon: Icons.image_search_outlined,
              iconColor: AppColors.accent,
              title: '3 · Picture Words',
              subtitle: s.questsCards,
              trailing: s.play,
              onTap: () => context.push('/games/picture-words'),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              s.alsoAvailable,
              style: context.textTheme.titleSmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(
                backgroundColor: AppColors.primarySurface,
                child: Icon(Icons.smart_toy_outlined, color: AppColors.primary),
              ),
              title: Text(s.freeAiTutor),
              subtitle: Text(s.freeAiTutorHint),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/ai'),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(
                backgroundColor: AppColors.primarySurface,
                child: Icon(Icons.mic_outlined, color: AppColors.accent),
              ),
              title: Text(s.voiceCoach),
              subtitle: Text(s.voiceCoachHint),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/ai/voice'),
            ),
          ],
        ),
      ),
    );
  }
}

class _GameTile extends StatelessWidget {
  const _GameTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.isDark
          ? AppColors.surfaceElevatedDark
          : AppColors.surfaceElevated,
      borderRadius: AppRadius.borderXl,
      elevation: 0,
      shadowColor: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.borderXl,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: AppRadius.borderXl,
            border: Border.all(
              color: context.isDark ? AppColors.borderDark : AppColors.border,
            ),
            boxShadow: context.isDark ? null : AppShadows.soft,
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  borderRadius: AppRadius.borderLg,
                ),
                child: Icon(icon, color: iconColor, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: AppRadius.borderFull,
                ),
                child: Text(
                  trailing,
                  style: context.textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

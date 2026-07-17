import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/models/game_models.dart';
import '../../../../shared/widgets/safe_body.dart';
import '../../application/games_controller.dart';

class GamesHubScreen extends ConsumerWidget {
  const GamesHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final games = ref.watch(gamesControllerProvider);
    final quests = GameCatalog.quests;
    final doneCount = quests.where(games.isCompleted).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Games'),
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
              'Practice by playing',
              style: context.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Flashcards, AI quests, and picture word challenges.',
              style: context.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _GameTile(
              icon: Icons.style_outlined,
              iconColor: AppColors.secondary,
              title: '1 · Flashcards',
              subtitle: 'Flip cards and review your vocabulary',
              trailing: 'Play',
              onTap: () => context.push('/games/flashcards'),
            ),
            const SizedBox(height: 12),
            _GameTile(
              icon: Icons.theater_comedy_outlined,
              iconColor: AppColors.primary,
              title: '2 · AI Quest Chat',
              subtitle:
                  'Book a hotel, open a bank card… Level ${games.unlockedLevel} open · $doneCount/${quests.length} done',
              trailing: 'Levels',
              onTap: () => context.push('/games/quests'),
            ),
            const SizedBox(height: 12),
            _GameTile(
              icon: Icons.image_search_outlined,
              iconColor: AppColors.accent,
              title: '3 · Picture Words',
              subtitle:
                  'See a ball → write round, kick, play… Need more words each level',
              trailing: 'Play',
              onTap: () => context.push('/games/picture-words'),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Also available',
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
              title: const Text('Free AI tutor'),
              subtitle: const Text('Open chat without quest goals'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/ai'),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(
                backgroundColor: AppColors.primarySurface,
                child: Icon(Icons.mic_outlined, color: AppColors.accent),
              ),
              title: const Text('Voice coach'),
              subtitle: const Text('Pronunciation feedback'),
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
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
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
              Text(
                trailing,
                style: context.textTheme.labelLarge?.copyWith(
                  color: AppColors.primary,
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

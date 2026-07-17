import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/models/game_models.dart';
import '../../../../shared/widgets/safe_body.dart';
import '../../application/games_controller.dart';

class QuestLevelsScreen extends ConsumerWidget {
  const QuestLevelsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final games = ref.watch(gamesControllerProvider);
    final quests = GameCatalog.quests;

    return Scaffold(
      appBar: AppBar(title: const Text('AI Quest Chat')),
      body: SafeBody(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                'Talk to an NPC and complete the checklist. '
                'Finish a level to unlock the next theme — harder language each time.',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Unlocked through level ${games.unlockedLevel}',
              style: context.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            ...quests.map((q) {
              final unlocked = games.isUnlocked(q);
              final done = games.isCompleted(q);
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Material(
                  color: context.isDark
                      ? AppColors.surfaceElevatedDark
                      : AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: unlocked
                        ? () {
                            ref
                                .read(gamesControllerProvider.notifier)
                                .startQuest(q.id);
                            context.push('/games/quests/${q.id}');
                          }
                        : () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Complete level ${q.level - 1} first',
                                ),
                              ),
                            );
                          },
                    child: Opacity(
                      opacity: unlocked ? 1 : 0.55,
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: q.difficulty.color.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                unlocked ? q.icon : Icons.lock_outline,
                                color: q.difficulty.color,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'Lv ${q.level}',
                                        style: context.textTheme.labelMedium
                                            ?.copyWith(
                                          color: q.difficulty.color,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.primarySurface,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          q.theme,
                                          style: context.textTheme.labelSmall,
                                        ),
                                      ),
                                      if (done) ...[
                                        const SizedBox(width: 6),
                                        const Icon(
                                          Icons.check_circle,
                                          size: 16,
                                          color: AppColors.success,
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    q.title,
                                    style: context.textTheme.titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                  Text(
                                    q.subtitle,
                                    style: context.textTheme.bodySmall
                                        ?.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${q.difficulty.label} · +${q.xpReward} XP · ${q.goals.length} goals',
                                    style: context.textTheme.labelSmall
                                        ?.copyWith(
                                      color: AppColors.textTertiary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

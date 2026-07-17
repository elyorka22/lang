import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/models/game_models.dart';
import '../../../../shared/widgets/safe_body.dart';
import '../../application/picture_words_controller.dart';

class PictureWordsLevelsScreen extends ConsumerWidget {
  const PictureWordsLevelsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(pictureWordsControllerProvider);
    final levels = PictureWordsCatalog.levels;

    return Scaffold(
      appBar: AppBar(title: const Text('Picture Words')),
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
                'See the picture, write words that fit it — round, kick, play… '
                'Each level needs more words to pass.',
                style: context.textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Unlocked through level ${state.unlockedLevel}',
              style: context.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            ...levels.map((level) {
              final unlocked = state.isUnlocked(level);
              final done = state.isCompleted(level);
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
                                .read(pictureWordsControllerProvider.notifier)
                                .startLevel(level.id);
                            context.push('/games/picture-words/${level.id}');
                          }
                        : () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Complete level ${level.level - 1} first',
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
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: level.color.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(
                                unlocked ? level.icon : Icons.lock_outline,
                                color: level.color,
                                size: 30,
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
                                        'Lv ${level.level}',
                                        style: context.textTheme.labelMedium
                                            ?.copyWith(
                                          color: level.color,
                                          fontWeight: FontWeight.w700,
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
                                  Text(
                                    level.word,
                                    style: context.textTheme.titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                  Text(
                                    'Write at least ${level.minWords} words · +${level.xpReward} XP',
                                    style: context.textTheme.bodySmall
                                        ?.copyWith(
                                      color: AppColors.textSecondary,
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

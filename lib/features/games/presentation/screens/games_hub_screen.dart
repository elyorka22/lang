import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/providers/locale_provider.dart';
import '../../../../shared/widgets/premium_card.dart';

class GamesHubScreen extends ConsumerWidget {
  const GamesHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(appStringsProvider);

    final games = [
      (
        Icons.compare_arrows_rounded,
        AppColors.primary,
        s.gameMatchMeaning,
        s.gameMatchMeaningHint,
        '/games/match-meaning',
      ),
      (
        Icons.image_search_rounded,
        AppColors.accent,
        s.gameImageWord,
        s.gameImageWordHint,
        '/games/image-word',
      ),
      (
        Icons.abc_rounded,
        AppColors.warning,
        s.gameWordBuilder,
        s.gameWordBuilderHint,
        '/games/word-builder',
      ),
      (
        Icons.grid_view_rounded,
        AppColors.success,
        s.gameMemoryCards,
        s.gameMemoryCardsHint,
        '/games/memory-cards',
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(s.navGames)),
      body: ListView(
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
          for (final g in games) ...[
            PremiumCard(
              onTap: () => context.push(g.$5),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: g.$2.withOpacity(0.12),
                      borderRadius: AppRadius.borderLg,
                    ),
                    child: Icon(g.$1, color: g.$2, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          g.$3,
                          style: context.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(g.$4, style: context.textTheme.bodySmall),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: AppRadius.borderFull,
                    ),
                    child: Text(
                      s.play,
                      style: context.textTheme.labelLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

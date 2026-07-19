import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/providers/locale_provider.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/premium_card.dart';
import '../../../../shared/widgets/safe_body.dart';
import '../../application/vocabulary_controller.dart';

class VocabularyScreen extends ConsumerWidget {
  const VocabularyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(vocabularyProvider);
    final s = ref.watch(appStringsProvider);
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final favorites = items.where((e) => e.isFavorite).length;
    final mastered = items.where((e) => e.intervalDays >= 7).length;

    return Scaffold(
      appBar: AppBar(
        title: Text(s.navVocab),
        actions: [
          IconButton(
            onPressed: () => context.push('/games/flashcards'),
            icon: const Icon(Icons.style_outlined),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/games/flashcards'),
        icon: const Icon(Icons.play_arrow_rounded),
        label: Text(s.review),
      ),
      body: items.isEmpty
          ? SafeBody(
              child: EmptyState(
                icon: Icons.menu_book_outlined,
                title: s.noWordsYet,
                subtitle: s.noWordsHint,
              ),
            )
          : ListView(
              padding: EdgeInsets.fromLTRB(16, 8, 16, bottomInset + 88),
              children: [
                PremiumCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.vocabStats, style: context.textTheme.titleMedium),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          _StatPill(
                            label: s.totalWords,
                            value: '${items.length}',
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 10),
                          _StatPill(
                            label: s.favorites,
                            value: '$favorites',
                            color: AppColors.xpGold,
                          ),
                          const SizedBox(width: 10),
                          _StatPill(
                            label: s.mastered,
                            value: '$mastered',
                            color: AppColors.accent,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _ReviewChip(
                        label: s.easy,
                        color: AppColors.success,
                        onTap: () => context.push('/games/flashcards'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _ReviewChip(
                        label: s.medium,
                        color: AppColors.warning,
                        onTap: () => context.push('/games/flashcards'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _ReviewChip(
                        label: s.hard,
                        color: AppColors.error,
                        onTap: () => context.push('/games/flashcards'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...items.map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: PremiumCard(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.word,
                                  style: context.textTheme.titleMedium,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  item.translation,
                                  style: context.textTheme.bodyMedium?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                if (item.example.isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    item.example,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: context.textTheme.bodySmall,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          IconButton(
                            tooltip: s.pronunciation,
                            onPressed: () {},
                            icon: const Icon(
                              Icons.volume_up_rounded,
                              color: AppColors.primary,
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              item.isFavorite
                                  ? Icons.star_rounded
                                  : Icons.star_border_rounded,
                              color: item.isFavorite ? AppColors.xpGold : null,
                            ),
                            onPressed: () => ref
                                .read(vocabularyProvider.notifier)
                                .toggleFavorite(item.id),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: AppRadius.borderLg,
        ),
        child: Column(
          children: [
            Text(
              value,
              style: context.textTheme.titleLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(label, style: context.textTheme.labelSmall),
          ],
        ),
      ),
    );
  }
}

class _ReviewChip extends StatelessWidget {
  const _ReviewChip({
    required this.label,
    required this.color,
    required this.onTap,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withOpacity(0.12),
      borderRadius: AppRadius.borderLg,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.borderLg,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: context.textTheme.labelLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

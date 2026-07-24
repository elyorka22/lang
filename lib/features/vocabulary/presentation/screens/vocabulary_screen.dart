import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/data/vocab_deck.dart';
import '../../../../shared/l10n/app_strings.dart';
import '../../../../shared/models/vocabulary_item.dart';
import '../../../../shared/providers/locale_provider.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../../../../shared/widgets/premium_card.dart';
import '../../application/vocabulary_controller.dart';

class VocabularyScreen extends ConsumerWidget {
  const VocabularyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(vocabularyProvider);
    final s = ref.watch(appStringsProvider);
    final items = state.filtered;

    if (state.isLoading) {
      return const Scaffold(body: HomeShimmer());
    }

    return Scaffold(
      appBar: AppBar(title: Text(s.navWords)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              onChanged: (v) =>
                  ref.read(vocabularyProvider.notifier).setQuery(v),
              decoration: InputDecoration(
                hintText: s.searchWords,
                prefixIcon: const Icon(Icons.search),
              ),
            ),
          ),
          SizedBox(
            height: 42,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(s.all),
                    selected: state.categoryFilter == null,
                    onSelected: (_) =>
                        ref.read(vocabularyProvider.notifier).setCategory(null),
                  ),
                ),
                ...VocabDeck.categories.map(
                  (c) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(c),
                      selected: state.categoryFilter == c,
                      onSelected: (_) => ref
                          .read(vocabularyProvider.notifier)
                          .setCategory(c),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: items.isEmpty
                ? EmptyState(
                    icon: Icons.menu_book_outlined,
                    title: s.noWordsYet,
                    subtitle: s.noWordsHint,
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) {
                      final item = items[i];
                      return PremiumCard(
                        onTap: () => context.push('/words/${item.id}'),
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: AppColors.primarySurface,
                                borderRadius: AppRadius.borderLg,
                              ),
                              child: Text(
                                item.word.substring(0, 1).toUpperCase(),
                                style: context.textTheme.titleLarge?.copyWith(
                                  color: AppColors.primaryDark,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.word,
                                    style: context.textTheme.titleMedium,
                                  ),
                                  Text(
                                    '${item.ipa} · ${item.translation}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: context.textTheme.bodySmall,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${item.category} · ${item.cefrLabel} · ${_statusLabel(item.srsStatus, s)}',
                                    style: context.textTheme.labelSmall?.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                item.isFavorite
                                    ? Icons.star_rounded
                                    : Icons.star_border_rounded,
                                color:
                                    item.isFavorite ? AppColors.xpGold : null,
                              ),
                              onPressed: () => ref
                                  .read(vocabularyProvider.notifier)
                                  .toggleFavorite(item.id),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  String _statusLabel(SrsStatus status, AppStrings s) {
    switch (status) {
      case SrsStatus.newWord:
        return s.srsNew;
      case SrsStatus.learning:
        return s.srsLearning;
      case SrsStatus.review:
        return s.srsReview;
      case SrsStatus.mastered:
        return s.srsMastered;
    }
  }
}

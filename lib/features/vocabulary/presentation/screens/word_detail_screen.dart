import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/models/vocabulary_item.dart';
import '../../../../shared/providers/locale_provider.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/premium_card.dart';
import '../../application/vocabulary_controller.dart';

class WordDetailScreen extends ConsumerWidget {
  const WordDetailScreen({super.key, required this.wordId});

  final String wordId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(appStringsProvider);
    final items = ref.watch(vocabularyProvider).items;
    VocabularyItem? item;
    for (final e in items) {
      if (e.id == wordId) {
        item = e;
        break;
      }
    }

    if (item == null) {
      return Scaffold(
        appBar: AppBar(title: Text(s.navWords)),
        body: EmptyState(
          icon: Icons.search_off,
          title: s.noWordsYet,
          subtitle: s.noWordsHint,
        ),
      );
    }

    final word = item;

    return Scaffold(
      appBar: AppBar(
        title: Text(word.word),
        actions: [
          IconButton(
            icon: Icon(
              word.isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
              color: word.isFavorite ? AppColors.xpGold : null,
            ),
            onPressed: () =>
                ref.read(vocabularyProvider.notifier).toggleFavorite(word.id),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          PremiumCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  word.word,
                  style: context.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  word.ipa,
                  style: context.textTheme.titleMedium?.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '${word.translationUz} · ${word.translationRu}',
                  style: context.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    Chip(label: Text(word.category)),
                    Chip(label: Text(word.cefrLabel)),
                    Chip(label: Text(word.difficulty.name)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _Section(title: s.definition, body: word.definition),
          _Section(title: s.exampleSentence, body: word.example),
          if (word.synonyms.isNotEmpty)
            _Chips(title: s.synonyms, values: word.synonyms),
          if (word.antonyms.isNotEmpty)
            _Chips(title: s.antonyms, values: word.antonyms),
          if (word.collocations.isNotEmpty)
            _Chips(title: s.collocations, values: word.collocations),
          if (word.verbForms.isNotEmpty)
            _Chips(title: s.verbForms, values: word.verbForms),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () {
              ref.read(vocabularyProvider.notifier).setInDeck(word.id, true);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(s.addedToDeck)),
              );
            },
            child: Text(s.addToDeck),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.body});
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    if (body.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: PremiumCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 6),
            Text(body, style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}

class _Chips extends StatelessWidget {
  const _Chips({required this.title, required this.values});
  final String title;
  final List<String> values;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: PremiumCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: values.map((e) => Chip(label: Text(e))).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

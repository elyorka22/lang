import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/safe_body.dart';
import '../../application/vocabulary_controller.dart';

class VocabularyScreen extends ConsumerWidget {
  const VocabularyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(vocabularyProvider);
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vocabulary'),
        actions: [
          IconButton(
            onPressed: () => context.push('/vocabulary/flashcards'),
            icon: const Icon(Icons.style_outlined),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/vocabulary/flashcards'),
        icon: const Icon(Icons.play_arrow_rounded),
        label: const Text('Review'),
      ),
      body: items.isEmpty
          ? const SafeBody(
              child: EmptyState(
                icon: Icons.menu_book_outlined,
                title: 'No words yet',
                subtitle: 'Save words from chats or AI lessons',
              ),
            )
          : ListView.separated(
              padding: EdgeInsets.only(bottom: bottomInset + 88),
              itemCount: items.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final item = items[i];
                return ListTile(
                  title: Text(item.word, style: context.textTheme.titleMedium),
                  subtitle: Text(
                    '${item.translation}\n${item.example}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  isThreeLine: true,
                  trailing: IconButton(
                    icon: Icon(
                      item.isFavorite ? Icons.star : Icons.star_border,
                      color: item.isFavorite ? AppColors.xpGold : null,
                    ),
                    onPressed: () => ref
                        .read(vocabularyProvider.notifier)
                        .toggleFavorite(item.id),
                  ),
                );
              },
            ),
    );
  }
}

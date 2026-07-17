import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/models/memorizer_item.dart';
import '../../../../shared/providers/locale_provider.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/safe_body.dart';
import '../../application/memorizer_controller.dart';

/// Запоминалка — words & phrases clipped from chats.
class MemorizerScreen extends ConsumerStatefulWidget {
  const MemorizerScreen({super.key});

  @override
  ConsumerState<MemorizerScreen> createState() => _MemorizerScreenState();
}

class _MemorizerScreenState extends ConsumerState<MemorizerScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  final _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    _search.dispose();
    super.dispose();
  }

  List<MemorizerItem> _filter(List<MemorizerItem> source) {
    final q = _search.text.trim().toLowerCase();
    if (q.isEmpty) return source;
    return source
        .where(
          (e) =>
              e.text.toLowerCase().contains(q) ||
              e.translation.toLowerCase().contains(q) ||
              e.note.toLowerCase().contains(q),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(memorizerProvider);
    final s = ref.watch(appStringsProvider);
    final words = _filter(
      items.where((e) => e.kind == MemorizerKind.word).toList(),
    );
    final phrases = _filter(
      items.where((e) => e.kind == MemorizerKind.phrase).toList(),
    );
    final all = _filter(items);

    return Scaffold(
      appBar: AppBar(
        title: Text(s.memorizer),
        bottom: TabBar(
          controller: _tabs,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: [
            Tab(text: '${s.all} (${all.length})'),
            Tab(text: '${s.words} (${words.length})'),
            Tab(text: '${s.phrases} (${phrases.length})'),
          ],
        ),
      ),
      body: SafeBody(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                controller: _search,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  hintText: 'Search saved words & phrases',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'In chat: select a word or phrase → Save to Запоминалка',
                style: context.textTheme.bodySmall,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: TabBarView(
                controller: _tabs,
                children: [
                  _List(items: all),
                  _List(items: words),
                  _List(items: phrases),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _List extends ConsumerWidget {
  const _List({required this.items});

  final List<MemorizerItem> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (items.isEmpty) {
      return const EmptyState(
        icon: Icons.bookmark_border_rounded,
        title: 'Empty for now',
        subtitle:
            'Highlight text in any chat and save it here — words and phrases',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final item = items[i];
        return Dismissible(
          key: ValueKey(item.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.delete_outline, color: AppColors.error),
          ),
          onDismissed: (_) =>
              ref.read(memorizerProvider.notifier).remove(item.id),
          child: Material(
            color: context.isDark
                ? AppColors.surfaceElevatedDark
                : AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => _editSheet(context, ref, item),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primarySurface,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item.kind == MemorizerKind.word ? 'Word' : 'Phrase',
                        style: context.textTheme.labelSmall?.copyWith(
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
                          Text(item.text, style: context.textTheme.titleMedium),
                          if (item.translation.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              item.translation,
                              style: context.textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                          if (item.contextSentence.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              '“${item.contextSentence}”',
                              style: context.textTheme.bodySmall?.copyWith(
                                fontStyle: FontStyle.italic,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          if (item.note.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              item.note,
                              style: context.textTheme.labelSmall,
                            ),
                          ],
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        item.isFavorite ? Icons.star : Icons.star_border,
                        color: item.isFavorite ? AppColors.xpGold : null,
                      ),
                      onPressed: () => ref
                          .read(memorizerProvider.notifier)
                          .toggleFavorite(item.id),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _editSheet(
    BuildContext context,
    WidgetRef ref,
    MemorizerItem item,
  ) {
    final translation = TextEditingController(text: item.translation);
    final note = TextEditingController(text: item.note);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: MediaQuery.viewInsetsOf(ctx).bottom + 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(item.text, style: ctx.textTheme.titleLarge),
                const SizedBox(height: 12),
                TextField(
                  controller: translation,
                  decoration: const InputDecoration(
                    labelText: 'Translation',
                    hintText: 'Optional',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: note,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Note',
                    hintText: 'Why you saved this',
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () {
                    ref
                        .read(memorizerProvider.notifier)
                        .updateTranslation(item.id, translation.text);
                    ref
                        .read(memorizerProvider.notifier)
                        .updateNote(item.id, note.text);
                    Navigator.pop(ctx);
                  },
                  child: const Text('Save changes'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

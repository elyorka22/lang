import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/models/conversation.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/safe_body.dart';
import '../../application/discover_controller.dart';
import '../../../chat/application/chat_controller.dart';

class DiscoverScreen extends ConsumerWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(discoverControllerProvider);
    final ctrl = ref.read(discoverControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover'),
        actions: [
          IconButton(
            tooltip: 'Create group',
            onPressed: () => context.push('/groups/create'),
            icon: const Icon(Icons.group_add_outlined),
          ),
        ],
      ),
      body: SafeBody(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: TextField(
                onChanged: ctrl.setQuery,
                decoration: const InputDecoration(
                  hintText: 'Search groups',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
            SizedBox(
              height: 86,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: LanguageFlagFilter.filters.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (_, i) {
                  final f = LanguageFlagFilter.filters[i];
                  final selected = state.selectedLanguageId == f.id;
                  return _FlagChip(
                    filter: f,
                    selected: selected,
                    onTap: () => ctrl.setLanguageFilter(f.id),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Text(
                state.selectedFilter.languageCode.isEmpty
                    ? '${state.groups.length} groups'
                    : '${state.groups.length} · ${state.selectedFilter.label} chats',
                style: context.textTheme.labelLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            Expanded(
              child: state.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : state.groups.isEmpty
                      ? const EmptyState(
                          icon: Icons.groups_outlined,
                          title: 'No groups found',
                          subtitle: 'Try another language flag or search',
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                          itemCount: state.groups.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (_, i) {
                            final g = state.groups[i];
                            return _GroupTile(
                              group: g,
                              onTap: () => _openGroup(context, ref, g),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  void _openGroup(
    BuildContext context,
    WidgetRef ref,
    ChatConversation group,
  ) {
    ref.read(conversationsProvider.notifier).ensureGroup(group);
    context.push('/chat/${group.id}');
  }
}

class _FlagChip extends StatelessWidget {
  const _FlagChip({
    required this.filter,
    required this.selected,
    required this.onTap,
  });

  final LanguageFlagFilter filter;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: selected
                  ? AppColors.primarySurface
                  : (context.isDark
                      ? AppColors.surfaceElevatedDark
                      : AppColors.surface),
              border: Border.all(
                color: selected ? AppColors.primary : AppColors.border,
                width: selected ? 2.5 : 1,
              ),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.18),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Text(filter.flag, style: const TextStyle(fontSize: 26)),
          ),
          const SizedBox(height: 6),
          Text(
            filter.label,
            style: context.textTheme.labelSmall?.copyWith(
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupTile extends StatelessWidget {
  const _GroupTile({required this.group, required this.onTap});

  final ChatConversation group;
  final VoidCallback onTap;

  String get _flagEmoji {
    final code = group.flagCountryCode?.toUpperCase();
    for (final f in LanguageFlagFilter.filters) {
      if (f.countryCode == code) return f.flag;
    }
    if (code == 'EU') return '🌍';
    return '💬';
  }

  String get _langLabel {
    if (group.languageCodes.isEmpty) return 'Multi';
    return group.languageCodes.map((c) => c.toUpperCase()).join(' · ');
  }

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
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primarySurface,
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(_flagEmoji, style: const TextStyle(fontSize: 26)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.displayTitle,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      group.description.isEmpty
                          ? '${group.memberCount} members'
                          : group.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$_langLabel · ${group.memberCount} members',
                      style: context.textTheme.labelSmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chat_bubble_outline_rounded,
                color: AppColors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

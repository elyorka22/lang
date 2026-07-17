import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/widgets/app_avatar.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../application/discover_controller.dart';

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
            tooltip: state.isGrid ? 'List' : 'Cards',
            onPressed: ctrl.toggleView,
            icon: Icon(state.isGrid ? Icons.view_list_rounded : Icons.grid_view_rounded),
          ),
          IconButton(
            onPressed: () => _openFilters(context, ref),
            icon: const Icon(Icons.tune_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              onChanged: ctrl.setQuery,
              decoration: const InputDecoration(
                hintText: 'Search by name or username',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('Online'),
                  selected: state.filters.onlineOnly,
                  onSelected: (v) => ctrl.setFilters(
                    state.filters.copyWith(onlineOnly: v),
                  ),
                  selectedColor: AppColors.primarySurface,
                ),
                const SizedBox(width: 8),
                ActionChip(
                  label: Text(state.filters.nativeLanguage ?? 'Native'),
                  onPressed: () => _openFilters(context, ref),
                ),
                const SizedBox(width: 8),
                ActionChip(
                  label: Text(state.filters.learningLanguage ?? 'Learning'),
                  onPressed: () => _openFilters(context, ref),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: state.users.isEmpty
                ? const EmptyState(
                    icon: Icons.travel_explore,
                    title: 'No partners found',
                    subtitle: 'Try adjusting your filters',
                  )
                : state.isGrid
                    ? _CardSwipe(users: state.users)
                    : ListView.builder(
                        itemCount: state.users.length,
                        itemBuilder: (_, i) {
                          final u = state.users[i];
                          return ListTile(
                            onTap: () => context.push('/users/${u.id}'),
                            leading: AppAvatar(
                              name: u.displayName,
                              url: u.avatarUrl,
                              status: u.status,
                              showStatus: true,
                            ),
                            title: Text(u.displayName),
                            subtitle: Text(
                              '${u.nativeLanguage} · learning ${u.primaryLearning}\n${u.bio}',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            isThreeLine: true,
                            trailing: IconButton(
                              icon: const Icon(Icons.chat_bubble_outline),
                              onPressed: () => context.push('/chat/c_${u.id}'),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  void _openFilters(BuildContext context, WidgetRef ref) {
    final state = ref.read(discoverControllerProvider);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        var online = state.filters.onlineOnly;
        String? native = state.filters.nativeLanguage;
        return StatefulBuilder(
          builder: (ctx, setModal) {
            return Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Filters', style: ctx.textTheme.titleLarge),
                  SwitchListTile(
                    title: const Text('Online only'),
                    value: online,
                    onChanged: (v) => setModal(() => online = v),
                  ),
                  const SizedBox(height: 8),
                  Text('Native language', style: ctx.textTheme.titleSmall),
                  Wrap(
                    spacing: 8,
                    children: ['Spanish', 'German', 'French', 'Japanese', 'Portuguese']
                        .map((l) {
                      return ChoiceChip(
                        label: Text(l),
                        selected: native == l,
                        onSelected: (_) => setModal(() => native = l),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () {
                      ref.read(discoverControllerProvider.notifier).setFilters(
                            DiscoverFilters(
                              onlineOnly: online,
                              nativeLanguage: native,
                            ),
                          );
                      Navigator.pop(ctx);
                    },
                    child: const Text('Apply'),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _CardSwipe extends StatefulWidget {
  const _CardSwipe({required this.users});
  final List users;

  @override
  State<_CardSwipe> createState() => _CardSwipeState();
}

class _CardSwipeState extends State<_CardSwipe> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    if (index >= widget.users.length) {
      return const EmptyState(
        icon: Icons.check_circle_outline,
        title: 'You are all caught up',
        subtitle: 'Check back later for more partners',
      );
    }
    final u = widget.users[index];
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: context.isDark
                    ? AppColors.surfaceElevatedDark
                    : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
                border: Border.all(
                  color: context.isDark ? AppColors.borderDark : AppColors.border,
                ),
              ),
              child: Column(
                children: [
                  const Spacer(),
                  AppAvatar(
                    name: u.displayName,
                    url: u.avatarUrl,
                    size: 96,
                    status: u.status,
                    showStatus: true,
                  ),
                  const SizedBox(height: 16),
                  Text(u.displayName, style: context.textTheme.headlineSmall),
                  Text('@${u.username} · ${u.country ?? ''}'),
                  const SizedBox(height: 12),
                  Text(
                    u.bio,
                    textAlign: TextAlign.center,
                    style: context.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 6,
                    children: u.interests
                        .map<Widget>((e) => Chip(label: Text(e)))
                        .toList(),
                  ),
                  const Spacer(),
                  Text(
                    '${u.nativeLanguage} → ${u.primaryLearning} (${u.levelLabel})',
                    style: context.textTheme.titleSmall?.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _RoundAction(
                icon: Icons.close,
                color: AppColors.error,
                onTap: () => setState(() => index++),
              ),
              _RoundAction(
                icon: Icons.chat_bubble,
                color: AppColors.secondary,
                onTap: () => context.push('/chat/c_${u.id}'),
              ),
              _RoundAction(
                icon: Icons.favorite,
                color: AppColors.primary,
                onTap: () => setState(() => index++),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _RoundAction extends StatelessWidget {
  const _RoundAction({
    required this.icon,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withOpacity(0.12),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 60,
          height: 60,
          child: Icon(icon, color: color),
        ),
      ),
    );
  }
}

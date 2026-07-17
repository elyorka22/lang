import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/data/mock_data.dart';
import '../../../../shared/models/user_profile.dart';
import '../../../../shared/widgets/app_avatar.dart';
import '../../../../shared/widgets/lingua_button.dart';
import '../../application/chat_controller.dart';

/// Telegram-style create group: pick members → name the group.
class CreateGroupScreen extends ConsumerStatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  ConsumerState<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends ConsumerState<CreateGroupScreen> {
  final _selected = <UserProfile>{};
  final _name = TextEditingController();
  final _description = TextEditingController();
  final _search = TextEditingController();
  var _step = 0;
  var _creating = false;

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _search.dispose();
    super.dispose();
  }

  List<UserProfile> get _filtered {
    final q = _search.text.trim().toLowerCase();
    return MockData.users.where((u) {
      if (q.isEmpty) return true;
      return u.displayName.toLowerCase().contains(q) ||
          u.username.toLowerCase().contains(q);
    }).toList();
  }

  Future<void> _create() async {
    if (_name.text.trim().isEmpty || _selected.isEmpty) return;
    setState(() => _creating = true);
    final group = await ref.read(conversationsProvider.notifier).createGroup(
          title: _name.text,
          description: _description.text,
          members: _selected.toList(),
        );
    if (!mounted) return;
    context.go('/chats');
    context.push('/chat/${group.id}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_step == 0 ? 'New group' : 'Group info'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_step == 1) {
              setState(() => _step = 0);
            } else {
              context.pop();
            }
          },
        ),
      ),
      body: _step == 0 ? _membersStep() : _detailsStep(),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: LinguaButton(
            label: _step == 0 ? 'Next' : 'Create group',
            isLoading: _creating,
            onPressed: _step == 0
                ? (_selected.isEmpty
                    ? null
                    : () => setState(() => _step = 1))
                : (_name.text.trim().isEmpty ? null : _create),
          ),
        ),
      ),
    );
  }

  Widget _membersStep() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: TextField(
            controller: _search,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              hintText: 'Search people',
              prefixIcon: Icon(Icons.search),
            ),
          ),
        ),
        if (_selected.isNotEmpty)
          SizedBox(
            height: 92,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _selected.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, i) {
                final u = _selected.elementAt(i);
                return Column(
                  children: [
                    Stack(
                      children: [
                        AppAvatar(name: u.displayName, url: u.avatarUrl, size: 52),
                        Positioned(
                          right: -2,
                          top: -2,
                          child: GestureDetector(
                            onTap: () => setState(() => _selected.remove(u)),
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.error,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              padding: const EdgeInsets.all(2),
                              child: const Icon(Icons.close, size: 12, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      width: 64,
                      child: Text(
                        u.displayName.split(' ').first,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: context.textTheme.labelSmall,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              _selected.isEmpty
                  ? 'Select at least 1 member'
                  : '${_selected.length} selected',
              style: context.textTheme.bodySmall,
            ),
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView.builder(
            itemCount: _filtered.length,
            itemBuilder: (_, i) {
              final u = _filtered[i];
              final selected = _selected.any((s) => s.id == u.id);
              return ListTile(
                onTap: () {
                  setState(() {
                    if (selected) {
                      _selected.removeWhere((s) => s.id == u.id);
                    } else {
                      _selected.add(u);
                    }
                  });
                },
                leading: AppAvatar(
                  name: u.displayName,
                  url: u.avatarUrl,
                  status: u.status,
                  showStatus: true,
                ),
                title: Text(u.displayName),
                subtitle: Text('@${u.username} · ${u.nativeLanguage}'),
                trailing: Checkbox(
                  value: selected,
                  activeColor: AppColors.primary,
                  onChanged: (_) {
                    setState(() {
                      if (selected) {
                        _selected.removeWhere((s) => s.id == u.id);
                      } else {
                        _selected.add(u);
                      }
                    });
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _detailsStep() {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Center(
          child: Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(28),
            ),
            child: const Icon(Icons.groups_rounded, size: 44, color: AppColors.primary),
          ),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _name,
          textCapitalization: TextCapitalization.sentences,
          onChanged: (_) => setState(() {}),
          decoration: const InputDecoration(
            labelText: 'Group name',
            hintText: 'e.g. Spanish Practice',
            prefixIcon: Icon(Icons.edit_outlined),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _description,
          maxLines: 3,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            labelText: 'Description (optional)',
            hintText: 'What will you practice together?',
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Members (${_selected.length + 1})',
          style: context.textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        ...[MockData.currentUser, ..._selected].map(
          (u) => ListTile(
            contentPadding: EdgeInsets.zero,
            leading: AppAvatar(name: u.displayName, url: u.avatarUrl, size: 40),
            title: Text(u.displayName),
            subtitle: Text(u.id == 'me' ? 'Admin · You' : '@${u.username}'),
          ),
        ),
      ],
    );
  }
}

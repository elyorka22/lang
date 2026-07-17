import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/models/game_models.dart';
import '../../../../shared/widgets/safe_body.dart';
import '../../application/games_controller.dart';

class QuestChatScreen extends ConsumerStatefulWidget {
  const QuestChatScreen({super.key, required this.questId});

  final String questId;

  @override
  ConsumerState<QuestChatScreen> createState() => _QuestChatScreenState();
}

class _QuestChatScreenState extends ConsumerState<QuestChatScreen> {
  final _input = TextEditingController();
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final games = ref.read(gamesControllerProvider);
      if (games.activeQuestId != widget.questId) {
        ref.read(gamesControllerProvider.notifier).startQuest(widget.questId);
      }
    });
  }

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _send() async {
    final text = _input.text;
    _input.clear();
    await ref.read(gamesControllerProvider.notifier).sendMessage(text);
    _scrollToEnd();
    final games = ref.read(gamesControllerProvider);
    if (games.questJustCompleted && mounted) {
      final quest = games.activeQuest;
      ref.read(gamesControllerProvider.notifier).clearJustCompletedFlag();
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Quest complete!'),
          content: Text(
            quest == null
                ? 'Nice work.'
                : 'You finished “${quest.title}”. +${quest.xpReward} XP.\nNext level unlocked.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                context.pop();
              },
              child: const Text('Back to levels'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final games = ref.watch(gamesControllerProvider);
    AiQuest? quest = games.activeQuest;
    if (quest == null) {
      for (final q in GameCatalog.quests) {
        if (q.id == widget.questId) quest = q;
      }
    }

    if (quest == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quest')),
        body: const SafeBody(
          child: Center(child: Text('Quest not found')),
        ),
      );
    }

    final doneGoals = games.completedGoalIds;
    final progress = quest.goals.isEmpty
        ? 0.0
        : doneGoals.where((id) => quest.goals.any((g) => g.id == id)).length /
            quest.goals.length;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(quest.title, style: const TextStyle(fontSize: 16)),
            Text(
              '${quest.roleName} · ${quest.theme}',
              style: context.textTheme.labelSmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Goals',
            onPressed: () => _showGoals(context, quest, doneGoals),
            icon: const Icon(Icons.checklist_rtl),
          ),
        ],
      ),
      body: SafeBody(
        child: Column(
          children: [
            LinearProgressIndicator(
              value: progress,
              minHeight: 3,
              backgroundColor: AppColors.border,
              color: AppColors.success,
            ),
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                children: quest.goals.map((g) {
                  final done = doneGoals.contains(g.id);
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Chip(
                      avatar: Icon(
                        done ? Icons.check_circle : Icons.radio_button_unchecked,
                        size: 16,
                        color: done ? AppColors.success : AppColors.textTertiary,
                      ),
                      label: Text(g.label, style: const TextStyle(fontSize: 12)),
                      visualDensity: VisualDensity.compact,
                      backgroundColor: done
                          ? AppColors.success.withOpacity(0.12)
                          : null,
                    ),
                  );
                }).toList(),
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: _scroll,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                itemCount:
                    games.messages.length + (games.isReplying ? 1 : 0),
                itemBuilder: (_, i) {
                  if (i >= games.messages.length) {
                    return const Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: Text('…'),
                      ),
                    );
                  }
                  final m = games.messages[i];
                  final isUser = m.role == 'user';
                  return Align(
                    alignment:
                        isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.sizeOf(context).width * 0.78,
                      ),
                      decoration: BoxDecoration(
                        color: isUser
                            ? AppColors.primary
                            : (context.isDark
                                ? AppColors.surfaceElevatedDark
                                : AppColors.surface),
                        borderRadius: BorderRadius.circular(16).copyWith(
                          bottomRight:
                              isUser ? const Radius.circular(4) : null,
                          bottomLeft:
                              !isUser ? const Radius.circular(4) : null,
                        ),
                      ),
                      child: Text(
                        m.content,
                        style: TextStyle(
                          color: isUser
                              ? AppColors.textOnPrimary
                              : (context.isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimary),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _input,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _send(),
                        decoration: InputDecoration(
                          hintText: 'Speak to the ${quest.roleName.toLowerCase()}…',
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      onPressed: games.isReplying ? null : _send,
                      icon: const Icon(Icons.send_rounded),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showGoals(
    BuildContext context,
    AiQuest quest,
    Set<String> doneGoals,
  ) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mission goals',
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                quest.setting,
                style: context.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              ...quest.goals.map((g) {
                final done = doneGoals.contains(g.id);
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    done ? Icons.check_circle : Icons.circle_outlined,
                    color: done ? AppColors.success : AppColors.textTertiary,
                  ),
                  title: Text(g.label),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/providers/locale_provider.dart';
import '../../../../shared/widgets/premium_card.dart';
import '../../application/ai_controller.dart';

class AiScreen extends ConsumerStatefulWidget {
  const AiScreen({super.key});

  @override
  ConsumerState<AiScreen> createState() => _AiScreenState();
}

class _AiScreenState extends ConsumerState<AiScreen> {
  final _input = TextEditingController();
  final _scroll = ScrollController();

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ai = ref.watch(aiControllerProvider);
    final s = ref.watch(appStringsProvider);

    final modes = [
      ('tutor', s.tutor, Icons.school_outlined),
      ('grammar', s.grammar, Icons.spellcheck_rounded),
      ('roleplay', s.roleplay, Icons.theater_comedy_outlined),
      ('ielts', s.ielts, Icons.workspace_premium_outlined),
    ];

    final quick = [
      (s.translation, Icons.translate_rounded, 'tutor'),
      (s.pronunciation, Icons.record_voice_over_outlined, 'tutor'),
      (s.grammar, Icons.spellcheck_rounded, 'grammar'),
      (s.roleplay, Icons.theater_comedy_outlined, 'roleplay'),
      (s.navVocab, Icons.menu_book_outlined, 'tutor'),
      (s.dailyLesson, Icons.auto_stories_outlined, 'tutor'),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(s.aiTutor),
        actions: [
          TextButton(
            onPressed: () => context.push('/premium'),
            child: Text(s.remainingFree(ai.remainingFree)),
          ),
          IconButton(
            onPressed: () => context.push('/ai/voice'),
            icon: const Icon(Icons.mic_outlined),
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: modes.map((m) {
                final selected = ai.mode == m.$1;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    avatar: Icon(m.$3, size: 16),
                    label: Text(m.$2),
                    selected: selected,
                    onSelected: (_) =>
                        ref.read(aiControllerProvider.notifier).setMode(m.$1),
                    selectedColor: AppColors.primarySurface,
                  ),
                );
              }).toList(),
            ),
          ),
          if (ai.messages.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: quick.map((q) {
                  return ActionChip(
                    avatar: Icon(q.$2, size: 16, color: AppColors.primary),
                    label: Text(q.$1),
                    onPressed: () {
                      ref.read(aiControllerProvider.notifier).setMode(q.$3);
                      _input.text = q.$1;
                    },
                    backgroundColor: context.isDark
                        ? AppColors.surfaceElevatedDark
                        : AppColors.secondary,
                  );
                }).toList(),
              ),
            ),
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              itemCount: ai.messages.length + (ai.isStreaming ? 1 : 0),
              itemBuilder: (_, i) {
                if (ai.isStreaming && i == ai.messages.length) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: PremiumCard(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      child: Text(
                        s.thinking,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  );
                }
                final m = ai.messages[i];
                final mine = m.role == 'user';
                return Align(
                  alignment:
                      mine ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.82,
                    ),
                    decoration: BoxDecoration(
                      color: mine
                          ? AppColors.primary
                          : (context.isDark
                              ? AppColors.surfaceElevatedDark
                              : AppColors.secondary),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(20),
                        topRight: const Radius.circular(20),
                        bottomLeft: Radius.circular(mine ? 20 : 6),
                        bottomRight: Radius.circular(mine ? 6 : 20),
                      ),
                      boxShadow: mine ? null : AppShadows.soft,
                    ),
                    child: Text(
                      m.content,
                      style: TextStyle(
                        color: mine
                            ? Colors.white
                            : (context.isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimary),
                        height: 1.45,
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
                      minLines: 1,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: s.askAnything,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: () async {
                      final text = _input.text;
                      _input.clear();
                      await ref.read(aiControllerProvider.notifier).send(text);
                      if (_scroll.hasClients) {
                        _scroll.animateTo(
                          _scroll.position.maxScrollExtent + 120,
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOut,
                        );
                      }
                    },
                    icon: const Icon(Icons.send_rounded),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

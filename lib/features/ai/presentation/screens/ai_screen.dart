import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/extensions.dart';
import '../../application/ai_controller.dart';

class AiScreen extends ConsumerStatefulWidget {
  const AiScreen({super.key});

  @override
  ConsumerState<AiScreen> createState() => _AiScreenState();
}

class _AiScreenState extends ConsumerState<AiScreen> {
  final _input = TextEditingController();
  final _scroll = ScrollController();

  static const _modes = [
    ('tutor', 'Tutor', Icons.school_outlined),
    ('grammar', 'Grammar', Icons.spellcheck),
    ('roleplay', 'Roleplay', Icons.theater_comedy_outlined),
    ('ielts', 'IELTS', Icons.workspace_premium_outlined),
  ];

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ai = ref.watch(aiControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Tutor'),
        actions: [
          TextButton(
            onPressed: () => context.push('/premium'),
            child: Text('${ai.remainingFree} left'),
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
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: _modes.map((m) {
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
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.all(16),
              itemCount: ai.messages.length + (ai.isStreaming ? 1 : 0),
              itemBuilder: (_, i) {
                if (ai.isStreaming && i == ai.messages.length) {
                  return const Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: Text('Thinking…'),
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
                    padding: const EdgeInsets.all(14),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.82,
                    ),
                    decoration: BoxDecoration(
                      color: mine
                          ? AppColors.primary
                          : (context.isDark
                              ? AppColors.surfaceElevatedDark
                              : AppColors.surface),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text(
                      m.content,
                      style: TextStyle(
                        color: mine ? Colors.white : null,
                        height: 1.4,
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
                      decoration: const InputDecoration(
                        hintText: 'Ask anything about languages…',
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

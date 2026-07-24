import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions.dart';
import '../../../pronunciation/application/pronunciation_controller.dart';
import '../../../pronunciation/presentation/widgets/pronunciation_checker_panel.dart';
import '../../application/vocabulary_controller.dart';

class FlashcardsScreen extends ConsumerStatefulWidget {
  const FlashcardsScreen({super.key});

  @override
  ConsumerState<FlashcardsScreen> createState() => _FlashcardsScreenState();
}

class _FlashcardsScreenState extends ConsumerState<FlashcardsScreen> {
  int _index = 0;
  bool _flipped = false;

  String _practiceText(String word, String translation, String example) {
    if (_flipped && example.trim().isNotEmpty) return example.trim();
    if (_flipped) return translation.trim();
    return word.trim();
  }

  void _nextCard(int total) {
    ref.read(pronunciationControllerProvider.notifier).reset();
    setState(() {
      _index++;
      _flipped = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(vocabularyProvider);

    if (items.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Flashcards')),
        body: const Center(child: Text('Nothing to review')),
      );
    }
    if (_index >= items.length) {
      return Scaffold(
        appBar: AppBar(title: const Text('Flashcards')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.emoji_events_outlined,
                size: 64,
                color: AppColors.xpGold,
              ),
              const SizedBox(height: 12),
              Text(
                'Session complete!',
                style: context.textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  ref.read(pronunciationControllerProvider.notifier).reset();
                  setState(() {
                    _index = 0;
                    _flipped = false;
                  });
                },
                child: const Text('Restart'),
              ),
            ],
          ),
        ),
      );
    }

    final item = items[_index];
    final practiceText =
        _practiceText(item.word, item.translation, item.example);

    return Scaffold(
      appBar: AppBar(
        title: Text('Card ${_index + 1}/${items.length}'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.md,
          ),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          ref
                              .read(pronunciationControllerProvider.notifier)
                              .reset();
                          setState(() => _flipped = !_flipped);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          width: double.infinity,
                          constraints: const BoxConstraints(minHeight: 180),
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: context.isDark
                                ? AppColors.surfaceElevatedDark
                                : Colors.white,
                            borderRadius: AppRadius.borderXl,
                            border: Border.all(
                              color: context.isDark
                                  ? AppColors.borderDark
                                  : AppColors.border,
                            ),
                            boxShadow: AppShadows.soft,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _flipped ? item.translation : item.word,
                                style: context.textTheme.headlineMedium,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _flipped
                                    ? item.definition
                                    : (item.pronunciation.isEmpty
                                        ? 'Tap to flip'
                                        : item.pronunciation),
                                textAlign: TextAlign.center,
                                style: context.textTheme.bodyLarge?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              if (_flipped && item.example.isNotEmpty) ...[
                                const SizedBox(height: 20),
                                Text(
                                  item.example,
                                  textAlign: TextAlign.center,
                                  style: context.textTheme.titleMedium,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      PronunciationCheckerPanel(
                        key: ValueKey('${item.id}-$_flipped'),
                        expectedText: practiceText,
                        localeId: item.sourceLanguage,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        ref
                            .read(vocabularyProvider.notifier)
                            .review(item.id, remembered: false);
                        _nextCard(items.length);
                      },
                      child: const Text('Again'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        ref
                            .read(vocabularyProvider.notifier)
                            .review(item.id, remembered: true);
                        _nextCard(items.length);
                      },
                      child: const Text('Got it'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

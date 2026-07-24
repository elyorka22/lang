import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/models/vocabulary_item.dart';
import '../../../../shared/providers/locale_provider.dart';
import '../../../../shared/widgets/empty_state.dart';
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
  List<VocabularyItem> _queue = const [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final due = ref.read(vocabularyProvider).dueQueue;
    if (_queue.isEmpty && due.isNotEmpty) {
      _queue = List.of(due);
    }
  }

  void _refreshQueue() {
    _queue = List.of(ref.read(vocabularyProvider).dueQueue);
    _index = 0;
    _flipped = false;
  }

  void _grade(ReviewGrade grade) {
    if (_index >= _queue.length) return;
    final item = _queue[_index];
    ref.read(vocabularyProvider.notifier).review(item.id, grade);
    ref.read(pronunciationControllerProvider.notifier).reset();
    setState(() {
      _index++;
      _flipped = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(appStringsProvider);
    final vocab = ref.watch(vocabularyProvider);

    ref.listen<PronunciationState>(pronunciationControllerProvider, (prev, next) {
      if (next.status != PronunciationStatus.done) return;
      final score = next.result?.score;
      if (score == null) return;
      if (prev?.result?.score == score &&
          prev?.status == PronunciationStatus.done) {
        return;
      }
      ref.read(vocabularyProvider.notifier).recordPronunciationScore(score);
    });

    if (vocab.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_queue.isEmpty) {
      _queue = List.of(vocab.dueQueue);
    }

    if (_queue.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(s.navPractice)),
        body: EmptyState(
          icon: Icons.check_circle_outline,
          title: s.sessionComplete,
          subtitle: s.noWordsDue,
          action: FilledButton(
            onPressed: () {
              setState(() {
                _queue = List.of(vocab.deck.take(10));
                _index = 0;
                _flipped = false;
              });
            },
            child: Text(s.practiceAnyway),
          ),
        ),
      );
    }

    if (_index >= _queue.length) {
      return Scaffold(
        appBar: AppBar(title: Text(s.navPractice)),
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
              Text(s.sessionComplete, style: context.textTheme.headlineSmall),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  ref.read(pronunciationControllerProvider.notifier).reset();
                  setState(_refreshQueue);
                },
                child: Text(s.restart),
              ),
            ],
          ),
        ),
      );
    }

    final item = _queue[_index];
    final practiceText =
        _flipped && item.example.trim().isNotEmpty
            ? item.example.trim()
            : (_flipped ? item.translation : item.word);

    return Scaffold(
      appBar: AppBar(
        title: Text('${s.navPractice} ${_index + 1}/${_queue.length}'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.lg,
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
                                    : (item.ipa.isEmpty
                                        ? s.tapToFlip
                                        : item.ipa),
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
                        localeId: 'en',
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
                      onPressed: () => _grade(ReviewGrade.again),
                      child: Text(s.again),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _grade(ReviewGrade.hard),
                      child: Text(s.hard),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => _grade(ReviewGrade.good),
                      child: Text(s.good),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => _grade(ReviewGrade.easy),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.success,
                      ),
                      child: Text(s.easy),
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

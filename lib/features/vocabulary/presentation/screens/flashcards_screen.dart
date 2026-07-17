import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/widgets/lingua_button.dart';
import '../../../../shared/widgets/safe_body.dart';
import '../../application/vocabulary_controller.dart';

class FlashcardsScreen extends ConsumerStatefulWidget {
  const FlashcardsScreen({super.key});

  @override
  ConsumerState<FlashcardsScreen> createState() => _FlashcardsScreenState();
}

class _FlashcardsScreenState extends ConsumerState<FlashcardsScreen> {
  int _index = 0;
  bool _flipped = false;

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(vocabularyProvider);
    if (items.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Flashcards')),
        body: const SafeBody(
          child: Center(child: Text('Nothing to review')),
        ),
      );
    }
    if (_index >= items.length) {
      return Scaffold(
        appBar: AppBar(title: const Text('Flashcards')),
        body: SafeBody(
          child: Center(
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
                LinguaButton(
                  label: 'Restart',
                  expand: false,
                  onPressed: () => setState(() {
                    _index = 0;
                    _flipped = false;
                  }),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final item = items[_index];
    return Scaffold(
      appBar: AppBar(
        title: Text('Card ${_index + 1}/${items.length}'),
      ),
      body: SafeBody(
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
                child: GestureDetector(
                  onTap: () => setState(() => _flipped = !_flipped),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: context.isDark
                          ? AppColors.surfaceElevatedDark
                          : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: context.isDark
                            ? AppColors.borderDark
                            : AppColors.border,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _flipped ? item.translation : item.word,
                          style: context.textTheme.displaySmall,
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
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        ref
                            .read(vocabularyProvider.notifier)
                            .review(item.id, remembered: false);
                        setState(() {
                          _index++;
                          _flipped = false;
                        });
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
                        setState(() {
                          _index++;
                          _flipped = false;
                        });
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

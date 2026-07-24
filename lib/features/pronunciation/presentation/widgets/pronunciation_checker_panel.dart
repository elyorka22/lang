import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/l10n/app_strings.dart';
import '../../../../shared/models/pronunciation_result.dart';
import '../../../../shared/providers/locale_provider.dart';
import '../../application/pronunciation_controller.dart';

/// Reusable pronunciation checker: mic, stop, results, word-by-word colors.
class PronunciationCheckerPanel extends ConsumerStatefulWidget {
  const PronunciationCheckerPanel({
    super.key,
    required this.expectedText,
    this.localeId,
  });

  final String expectedText;
  final String? localeId;

  @override
  ConsumerState<PronunciationCheckerPanel> createState() =>
      _PronunciationCheckerPanelState();
}

class _PronunciationCheckerPanelState
    extends ConsumerState<PronunciationCheckerPanel> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(pronunciationControllerProvider.notifier)
          .setExpectedText(widget.expectedText);
    });
  }

  @override
  void didUpdateWidget(covariant PronunciationCheckerPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.expectedText != widget.expectedText) {
      ref
          .read(pronunciationControllerProvider.notifier)
          .setExpectedText(widget.expectedText);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pronunciationControllerProvider);
    final ctrl = ref.read(pronunciationControllerProvider.notifier);
    final s = ref.watch(appStringsProvider);
    final listening = state.isListening;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.isDark
            ? AppColors.surfaceElevatedDark
            : AppColors.secondary,
        borderRadius: AppRadius.borderXl,
        border: Border.all(
          color: context.isDark ? AppColors.borderDark : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            s.pronunciation,
            style: context.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            widget.expectedText,
            style: context.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _MicButton(
                listening: listening,
                enabled: !state.isBusy || listening,
                onTap: listening ? null : () => ctrl.startListening(
                      localeId: widget.localeId,
                    ),
              ),
              if (listening) ...[
                const SizedBox(width: 16),
                FilledButton.icon(
                  onPressed: () => ctrl.stopListening(),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.stop_rounded, size: 20),
                  label: Text(s.stopListening),
                ),
              ],
            ],
          ),
          if (listening) ...[
            const SizedBox(height: 12),
            Text(
              s.listening,
              textAlign: TextAlign.center,
              style: context.textTheme.labelLarge?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          if (state.status == PronunciationStatus.initializing) ...[
            const SizedBox(height: 12),
            const LinearProgressIndicator(minHeight: 3),
          ],
          if (state.recognizedText.isNotEmpty &&
              state.status != PronunciationStatus.idle) ...[
            const SizedBox(height: 14),
            Text(
              s.recognizedText,
              style: context.textTheme.labelMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              state.recognizedText,
              style: context.textTheme.bodyLarge,
            ),
          ],
          if (state.errorMessage != null) ...[
            const SizedBox(height: 12),
            Text(
              state.errorMessage!,
              style: context.textTheme.bodySmall?.copyWith(
                color: AppColors.error,
              ),
            ),
          ],
          if (state.result != null) ...[
            const SizedBox(height: 16),
            _ResultSection(result: state.result!, strings: s),
          ],
        ],
      ),
    );
  }
}

class _MicButton extends StatelessWidget {
  const _MicButton({
    required this.listening,
    required this.enabled,
    this.onTap,
  });

  final bool listening;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = listening ? AppColors.primary : AppColors.primaryDark;

    Widget mic = Material(
      color: color,
      shape: const CircleBorder(),
      elevation: listening ? 6 : 2,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: enabled ? onTap : null,
        child: SizedBox(
          width: 72,
          height: 72,
          child: Icon(
            listening ? Icons.graphic_eq_rounded : Icons.mic_rounded,
            color: Colors.white,
            size: 34,
          ),
        ),
      ),
    );

    if (listening) {
      mic = mic
          .animate(onPlay: (c) => c.repeat())
          .scale(
            begin: const Offset(1, 1),
            end: const Offset(1.08, 1.08),
            duration: 700.ms,
            curve: Curves.easeInOut,
          )
          .then()
          .scale(
            begin: const Offset(1.08, 1.08),
            end: const Offset(1, 1),
            duration: 700.ms,
            curve: Curves.easeInOut,
          );
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        if (listening)
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withOpacity(0.15),
            ),
          )
              .animate(onPlay: (c) => c.repeat())
              .scale(
                begin: const Offset(0.85, 0.85),
                end: const Offset(1.15, 1.15),
                duration: 1200.ms,
              )
              .fade(begin: 0.35, end: 0.05, duration: 1200.ms),
        mic,
      ],
    );
  }
}

class _ResultSection extends StatelessWidget {
  const _ResultSection({required this.result, required this.strings});

  final PronunciationResult result;
  final AppStrings strings;

  String _ratingLabel(PronunciationRating rating) {
    switch (rating) {
      case PronunciationRating.excellent:
        return strings.ratingExcellent;
      case PronunciationRating.good:
        return strings.ratingGood;
      case PronunciationRating.needsPractice:
        return strings.ratingNeedsPractice;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(
              strings.pronunciationScore(result.score),
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: _scoreColor(result.score),
              ),
            ),
            const Spacer(),
            if (result.isCorrect)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    strings.pronunciationCorrect,
                    style: const TextStyle(
                      color: AppColors.success,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.check_circle, color: AppColors.success),
                ],
              ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          strings.matchedWords,
          style: context.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final match in result.wordMatches) _WordChip(match: match),
          ],
        ),
        if (!result.isCorrect) ...[
          if (result.missingWords.isNotEmpty) ...[
            const SizedBox(height: 12),
            _IssueList(
              title: strings.missingWords,
              words: result.missingWords,
              color: AppColors.warning,
            ),
          ],
          if (result.extraWords.isNotEmpty) ...[
            const SizedBox(height: 8),
            _IssueList(
              title: strings.extraWords,
              words: result.extraWords,
              color: AppColors.error,
            ),
          ],
          if (result.incorrectWords.isNotEmpty) ...[
            const SizedBox(height: 8),
            _IssueList(
              title: strings.incorrectWords,
              words: result.incorrectWords,
              color: AppColors.error,
            ),
          ],
        ],
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _scoreColor(result.score).withOpacity(0.1),
            borderRadius: AppRadius.borderLg,
          ),
          child: Column(
            children: [
              Text(
                strings.overallScore(result.score),
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _ratingLabel(result.rating),
                style: context.textTheme.bodyMedium?.copyWith(
                  color: _scoreColor(result.score),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _scoreColor(int score) {
    if (score >= 90) return AppColors.success;
    if (score >= 75) return AppColors.primary;
    return AppColors.warning;
  }
}

class _WordChip extends StatelessWidget {
  const _WordChip({required this.match});

  final WordMatch match;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (match.status) {
      WordMatchStatus.correct => (Icons.check_rounded, AppColors.success),
      WordMatchStatus.incorrect => (Icons.close_rounded, AppColors.error),
      WordMatchStatus.missing => (Icons.remove_rounded, AppColors.warning),
      WordMatchStatus.extra => (Icons.add_rounded, AppColors.error),
    };

    final label = match.expected ?? match.recognized ?? '';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: AppRadius.borderFull,
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: context.textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _IssueList extends StatelessWidget {
  const _IssueList({
    required this.title,
    required this.words,
    required this.color,
  });

  final String title;
  final List<String> words;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: context.textTheme.labelMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: words
              .map(
                (w) => Chip(
                  label: Text(w),
                  backgroundColor: color.withOpacity(0.12),
                  side: BorderSide(color: color.withOpacity(0.3)),
                  labelStyle: TextStyle(color: color),
                  visualDensity: VisualDensity.compact,
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/models/game_models.dart';
import '../../../../shared/widgets/safe_body.dart';
import '../../application/games_controller.dart';
import '../../application/picture_words_controller.dart';

class PictureWordsPlayScreen extends ConsumerStatefulWidget {
  const PictureWordsPlayScreen({super.key, required this.levelId});

  final String levelId;

  @override
  ConsumerState<PictureWordsPlayScreen> createState() =>
      _PictureWordsPlayScreenState();
}

class _PictureWordsPlayScreenState
    extends ConsumerState<PictureWordsPlayScreen> {
  final _input = TextEditingController();
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final pw = ref.read(pictureWordsControllerProvider);
      if (pw.activeLevelId != widget.levelId) {
        ref
            .read(pictureWordsControllerProvider.notifier)
            .startLevel(widget.levelId);
      }
    });
  }

  @override
  void dispose() {
    _input.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final text = _input.text;
    _input.clear();
    final xp = ref.read(pictureWordsControllerProvider.notifier).submitWord(text);
    if (xp > 0) {
      ref.read(gamesControllerProvider.notifier).addXp(xp);
    }
    _focus.requestFocus();

    final pw = ref.read(pictureWordsControllerProvider);
    if (pw.justCompleted && mounted) {
      final level = pw.activeLevel;
      ref.read(pictureWordsControllerProvider.notifier).clearJustCompleted();
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Level clear!'),
          content: Text(
            level == null
                ? 'Nice vocabulary.'
                : 'You found ${level.minWords}+ words for “${level.word}”.\n+$xp XP · next level unlocked.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                context.pop();
              },
              child: const Text('Back to levels'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Keep playing'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final pw = ref.watch(pictureWordsControllerProvider);
    PictureWordLevel? level = pw.activeLevel;
    if (level == null) {
      for (final l in PictureWordsCatalog.levels) {
        if (l.id == widget.levelId) level = l;
      }
    }

    if (level == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Picture Words')),
        body: const SafeBody(
          child: Center(child: Text('Level not found')),
        ),
      );
    }

    final active = level;
    final progress = (pw.foundCount / active.minWords).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(
        title: Text('Level ${active.level} · ${active.word}'),
      ),
      body: SafeBody(
        child: Column(
          children: [
            LinearProgressIndicator(
              value: progress,
              minHeight: 3,
              backgroundColor: AppColors.border,
              color: active.color,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                children: [
                  AspectRatio(
                    aspectRatio: 1.15,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            active.color.withOpacity(0.22),
                            active.color.withOpacity(0.08),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: active.color.withOpacity(0.35),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(active.icon, size: 96, color: active.color),
                          const SizedBox(height: 12),
                          Text(
                            active.word,
                            style: context.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: active.color,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            active.hint,
                            textAlign: TextAlign.center,
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        'Need ${active.minWords} words',
                        style: context.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${pw.foundCount}/${active.minWords}',
                        style: context.textTheme.titleSmall?.copyWith(
                          color: active.color,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (pw.foundWords.isEmpty)
                    Text(
                      'Example for a ball: round, kick, play…',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    )
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: pw.foundWords.map((w) {
                        return Chip(
                          label: Text(w),
                          backgroundColor: active.color.withOpacity(0.12),
                          side: BorderSide.none,
                        );
                      }).toList(),
                    ),
                  if (pw.lastFeedback != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      pw.lastFeedback!,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: pw.lastFeedback!.startsWith('Nice') ||
                                pw.lastFeedback!.startsWith('Great')
                            ? AppColors.success
                            : AppColors.warning,
                      ),
                    ),
                  ],
                ],
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
                        focusNode: _focus,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _submit(),
                        decoration: InputDecoration(
                          hintText: 'Type a word…',
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
                      onPressed: _submit,
                      icon: const Icon(Icons.add_rounded),
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
}

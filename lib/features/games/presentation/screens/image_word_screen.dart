import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/models/vocabulary_item.dart';
import '../../../../shared/providers/locale_provider.dart';
import '../../../../shared/widgets/premium_card.dart';
import '../../../vocabulary/application/vocabulary_controller.dart';

class ImageWordScreen extends ConsumerStatefulWidget {
  const ImageWordScreen({super.key});

  @override
  ConsumerState<ImageWordScreen> createState() => _ImageWordScreenState();
}

class _ImageWordScreenState extends ConsumerState<ImageWordScreen> {
  late List<VocabularyItem> _session;
  var _index = 0;
  var _score = 0;
  var _done = false;
  var _ready = false;
  String? _feedback;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_ready) return;
    final deck = ref.read(vocabularyProvider).deck;
    _session = (List.of(deck)..shuffle(Random())).take(8).toList();
    _ready = true;
  }

  List<String> _options(VocabularyItem current) {
    final others = ref
        .read(vocabularyProvider)
        .deck
        .where((e) => e.id != current.id)
        .map((e) => e.word)
        .toList()
      ..shuffle(Random());
    final opts = [current.word, ...others.take(3)]..shuffle(Random());
    return opts;
  }

  void _choose(String word) {
    if (_done || _feedback != null) return;
    final current = _session[_index];
    final correct = word == current.word;
    setState(() {
      _feedback = correct ? 'correct' : 'wrong';
      if (correct) _score++;
    });
    Future<void>.delayed(const Duration(milliseconds: 650), () {
      if (!mounted) return;
      setState(() {
        _feedback = null;
        if (_index + 1 >= _session.length) {
          _done = true;
        } else {
          _index++;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(appStringsProvider);
    if (!_ready) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_done) {
      return Scaffold(
        appBar: AppBar(title: Text(s.gameImageWord)),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.emoji_events, size: 64, color: AppColors.xpGold),
              const SizedBox(height: 12),
              Text(s.sessionComplete, style: context.textTheme.headlineSmall),
              Text('${s.score}: $_score / ${_session.length}'),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: Text(s.done),
              ),
            ],
          ),
        ),
      );
    }

    final item = _session[_index];
    final opts = _options(item);
    final letter = item.word.substring(0, 1).toUpperCase();

    return Scaffold(
      appBar: AppBar(
        title: Text('${s.gameImageWord} ${_index + 1}/${_session.length}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            PremiumCard(
              padding: const EdgeInsets.all(24),
              child: AspectRatio(
                aspectRatio: 1.2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 96,
                      height: 96,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.primarySurface,
                        borderRadius: AppRadius.borderXl,
                      ),
                      child: Text(
                        letter,
                        style: context.textTheme.displayMedium?.copyWith(
                          color: AppColors.primaryDark,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      item.translation,
                      style: context.textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    Text(item.category, style: context.textTheme.bodySmall),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            for (final opt in opts)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _feedback == null ? () => _choose(opt) : null,
                    style: FilledButton.styleFrom(
                      backgroundColor: _feedback != null && opt == item.word
                          ? AppColors.success
                          : (_feedback == 'wrong' &&
                                  _feedback != null &&
                                  opt != item.word
                              ? null
                              : AppColors.primary),
                      minimumSize: const Size.fromHeight(52),
                    ),
                    child: Text(opt),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

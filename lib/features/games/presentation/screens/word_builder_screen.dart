import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/models/vocabulary_item.dart';
import '../../../../shared/providers/locale_provider.dart';
import '../../../vocabulary/application/vocabulary_controller.dart';

class WordBuilderScreen extends ConsumerStatefulWidget {
  const WordBuilderScreen({super.key});

  @override
  ConsumerState<WordBuilderScreen> createState() => _WordBuilderScreenState();
}

class _WordBuilderScreenState extends ConsumerState<WordBuilderScreen> {
  late List<VocabularyItem> _session;
  var _index = 0;
  var _score = 0;
  var _done = false;
  var _ready = false;
  late List<String> _letters;
  final _built = <String>[];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_ready) return;
    final deck = ref.read(vocabularyProvider).deck;
    _session = (List.of(deck)..shuffle(Random()))
        .where((e) => e.word.length <= 10)
        .take(8)
        .toList();
    if (_session.isEmpty) {
      _session = List.of(deck.take(8));
    }
    _shuffleLetters();
    _ready = true;
  }

  void _shuffleLetters() {
    final word = _session[_index].word.toLowerCase();
    _letters = word.split('')..shuffle(Random());
    _built.clear();
  }

  void _tapLetter(int i) {
    if (_done) return;
    setState(() {
      _built.add(_letters.removeAt(i));
      if (_letters.isEmpty) {
        final guess = _built.join();
        final target = _session[_index].word.toLowerCase();
        if (guess == target) {
          _score++;
          _advance();
        } else {
          _letters = [..._built, ..._letters]..shuffle(Random());
          _built.clear();
        }
      }
    });
  }

  void _advance() {
    if (_index + 1 >= _session.length) {
      _done = true;
    } else {
      _index++;
      _shuffleLetters();
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(appStringsProvider);
    if (!_ready) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_done) {
      return Scaffold(
        appBar: AppBar(title: Text(s.gameWordBuilder)),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.emoji_events, size: 64, color: AppColors.xpGold),
              Text(s.sessionComplete, style: context.textTheme.headlineSmall),
              Text('${s.score}: $_score / ${_session.length}'),
              const SizedBox(height: 16),
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

    return Scaffold(
      appBar: AppBar(
        title: Text('${s.gameWordBuilder} ${_index + 1}/${_session.length}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(item.translation, style: context.textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(item.definition, textAlign: TextAlign.center),
            const SizedBox(height: 28),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                for (final ch in _built)
                  _LetterChip(ch: ch, filled: true, onTap: null),
                for (var i = 0; i < item.word.length - _built.length; i++)
                  const _LetterChip(ch: '_', filled: false, onTap: null),
              ],
            ),
            const Spacer(),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: [
                for (var i = 0; i < _letters.length; i++)
                  _LetterChip(
                    ch: _letters[i],
                    filled: true,
                    onTap: () => _tapLetter(i),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => setState(_shuffleLetters),
              child: Text(s.reset),
            ),
          ],
        ),
      ),
    );
  }
}

class _LetterChip extends StatelessWidget {
  const _LetterChip({
    required this.ch,
    required this.filled,
    required this.onTap,
  });

  final String ch;
  final bool filled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: filled ? AppColors.primarySurface : AppColors.secondary,
      borderRadius: AppRadius.borderLg,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.borderLg,
        child: SizedBox(
          width: 44,
          height: 48,
          child: Center(
            child: Text(
              ch.toUpperCase(),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDark,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}
